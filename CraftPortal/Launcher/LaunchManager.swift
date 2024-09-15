//
//  LaunchManager.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import Foundation
import Path
import SwiftData

enum LaunchArguments: String, Equatable, Hashable {
    case authPlayerName = "auth_player_name"
    case versionName = "version_name"
    case gameDirectory = "game_directory"
    case assetsRoot = "assets_root"
    case assetsIndexName = "assets_index_name"
    case authUUID = "auth_uuid"
    case uuid
    case authAccessToken = "auth_access_token"
    case accessToken
    case clientId = "clientid"
    case authXUID = "auth_xuid"
    case userType = "user_type"
    case versionType = "version_type"
    case resolutionWidth = "resolution_width"
    case resolutionHeight = "resolution_height"
    case nativesDirectory = "natives_directory"
    case launcherName = "launcher_name"
    case launcherVersion = "launcher_version"
    case classpath
}

private let SHELL_EXECUTABLE = "/bin/bash"

typealias LaunchArgValueCollection = [LaunchArguments: String]
typealias LaunchPlainArgValueCollection = [String: String]
typealias LaunchFeatureCollection = [String: Bool?]
typealias LaunchArgPatchCollection = [String]

extension LaunchArgValueCollection {
    func plainArugments() -> LaunchPlainArgValueCollection {
        return [String: String](
            uniqueKeysWithValues: map {
                (key: LaunchArguments, value: String) in
                (key.rawValue, value)
            })
    }
}

enum LauncherState: Equatable {
    case idle
    case launching
}

enum LauncherError: Error, Equatable, CustomStringConvertible {
    var description: String {
        switch self {
        case .launchFailed:
            return "Launch failed"
        case let .noValidJVM(expected: expected, actual: actual):
            return "Expected JVM version \(expected), but found \(actual)"
        case .noGameProfile:
            return "No game profile selected"
        case .noPlayerProfile:
            return "No player profile selected"
        case let .cannotCreateShellExecutable(reason: reason):
            return "Cannot create shell executable: \(reason)"
        case .cannotFindFullMetadata:
            return "Cannot find full metadata"
        case let .verifyFailed(path):
            return "Verification of \(path) failed"
        }
    }

    case launchFailed
    case noValidJVM(expected: Int, actual: String)
    case noGameProfile
    case noPlayerProfile
    case cannotCreateShellExecutable(reason: String)
    case cannotFindFullMetadata
    case verifyFailed(path: String)
}

private func ensureQuotes(_ value: String) -> String {
    return value.hasPrefix("\"") && value.hasSuffix("\"")
        ? value : "\"\(value)\""
}

class LaunchManager {
    static let defaultLaunchFeatures: LaunchFeatureCollection = [
        "has_custom_resolution": true,
    ]

    private(set) var launcherStates: [UUID: [Process]] = [:]

    func registerProcess(for uuid: UUID, _ process: Process) {
        launcherStates[uuid, default: []].append(process)
    }

    func removeProcess(for uuid: UUID, _ process: Process) {
        launcherStates[uuid]?.removeAll(where: { $0 === process })
    }

    func noProcessRunning(for uuid: UUID) -> Bool {
        launcherStates[uuid, default: []].isEmpty
    }

    // TODO: maybe not mainactor
    @MainActor
    func launch(
        globalSettings: GlobalSettings,
        appState: AppState,
        taskNotifier notify: @MainActor @escaping (LaunchSubTask) -> Void,
        profile: GameProfile? = nil,
        pipe: Pipe? = nil
    ) async {
        notify(.step(.init(name: "Check player information")))

        guard let player = globalSettings.currentPlayerProfile else {
            appState.setError(
                title: "No Player Profile",
                description:
                "Please select a player profile before launching the game."
            )
            return
        }

        let playerId = player.id

        GLOBAL_LOGGER.debug("Start launching game")

        do {
            notify(.step(.init(name: "Check game profile")))

            guard
                let profile = profile
                ?? globalSettings.currentGameProfile
            else {
                throw LauncherError.noGameProfile
            }

            profile.lastPlayed = Date.now

            notify(.step(.init(name: "Generate launch script")))

            let script = try await composeLaunchScript(
                player: player,
                profile: profile,
                selectedJVM: globalSettings.selectedJVM,
                jvmManager: appState.jvmManager,
                gameSettings: profile.perGameSettingsOn
                    ? profile.gameSettings : globalSettings.gameSettings,
                notifier: notify
            )

            notify(.step(.init(name: "Execute launch script")))

            try executeScript(script, for: playerId, stdout: pipe, stderr: pipe) { process in
                if process.terminationStatus != 0 {
                    appState.setError(
                        title: "Game Exited Abnormally",
                        description:
                        "The exist code was not 0 but \(process.terminationStatus). Please check the logs for more information."
                    )
                }
            }

            GLOBAL_LOGGER.debug("Launch script executed")

            notify(.success)
        } catch let error as LauncherError {
            notify(.failed)
            appState.setError(
                title: "Experienced Launcher Error",
                description: error.description
            )
        } catch {
            notify(.failed)
            appState.setError(
                title: "Experienced Unknown Error",
                description: error.localizedDescription
            )
        }
    }

    static func createTemporaryBashScript(_ script: String) throws -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory

        let fileName = "mc-launch-\(UUID().uuidString).sh"

        let tempFileURL = tempDirectory.appendingPathComponent(fileName)

        let script = "#!/bin/bash\n\(script)\n"

        do {
            try script.write(to: tempFileURL, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o755], ofItemAtPath: tempFileURL.path
            )
        } catch {
            throw LauncherError.cannotCreateShellExecutable(
                reason: error.localizedDescription)
        }

        return tempFileURL
    }

    func executeScript(
        _ script: String, for uuid: UUID, stdout: Pipe? = nil,
        stderr: Pipe? = nil,
        endCallback: (@Sendable (Process) -> Void)? = nil
    ) throws {
        let script = try LaunchManager.createTemporaryBashScript(script)

        GLOBAL_LOGGER.debug("Script path \(script.path(percentEncoded: false))")

        let process = Process()

        process.executableURL = script
        process.standardOutput = stdout
        process.standardError = stderr
        process.terminationHandler = { [unowned self] process in
            if let endCallback {
                endCallback(process)
            }
            process.terminationHandler = nil
            self.removeProcess(for: uuid, process)
        }

        registerProcess(for: uuid, process)

        do {
            try process.run()
        } catch {
            removeProcess(for: uuid, process)
            throw error
        }
    }

    func getMinecraftMeta(
        from clientConfigPath: Path, versionDir clientVersionsDir: Path
    ) throws -> MinecraftMeta {
        let metadata = try loadClinetConfig(clientPath: clientConfigPath)
        let metaConfig: MinecraftMeta

        switch metadata {
        case let .full(fullConfig):
            metaConfig = fullConfig
        case let .inherits(inherits):
            let fullMetaLocation =
                clientVersionsDir / inherits.inheritsFrom
                    / "\(inherits.inheritsFrom).json"
            if case let .full(toBePatched) = try loadClinetConfig(
                clientPath: fullMetaLocation)
            {
                metaConfig = toBePatched.patch(with: inherits)
            } else {
                throw LauncherError.cannotFindFullMetadata
            }
        }

        return metaConfig
    }

    @MainActor
    func composeLaunchScript(
        player: PlayerProfile,
        profile: GameProfile,
        selectedJVM: SelectedJVM,
        jvmManager: JVMManager,
        gameSettings: GameSettings,
        notifier notify: @MainActor @escaping (LaunchSubTask) -> Void,
        verify: Bool = true
    ) async throws
        -> String
    {
        // TODO: restructure this pipeline, this is too ugly
        let gameDir = profile.gameDirectory
        let fullVersion = profile.fullVersion

        let metaPath: Path = gameDir.getMetaPath()

        let libraryPath = metaPath / "libraries"
        let assetsPath = metaPath / "assets"
        let nativesPath = metaPath / "natives" / fullVersion

        let clientVersionsDir = metaPath / "versions"
        let clientLocation = clientVersionsDir / fullVersion
        let clientJarPath = clientLocation / "\(fullVersion).jar"
        let clientConfigPath = clientLocation / "\(fullVersion).json"

        let profilePath: Path = profile.getProfilePath()

        notify(.step(.init(name: "Load Minecraft Metadata")))
        let metaConfig = try getMinecraftMeta(
            from: clientConfigPath, versionDir: clientVersionsDir
        )

        notify(.step(.init(name: "Verify Java Version")))
        guard
            let javaPathString = jvmManager.resolveJVM(
                for: selectedJVM, expected: metaConfig.javaVersion.majorVersion
            )?.path
        else {
            throw LauncherError.noValidJVM(
                expected: metaConfig.javaVersion.majorVersion,
                actual: selectedJVM.formattedVersion
            )
        }

        let javaPath = ensureQuotes(javaPathString)

        let resolutionSize = gameSettings.resolution.toSizeStrings()

        let accessToken = try await player.getAccessToken()

        let classPaths = composeClassPaths(
            from: metaConfig,
            withLibBase: libraryPath,
            withClientJar: clientJarPath,
            features: LaunchManager.defaultLaunchFeatures
        )

        if verify {
            notify(.step(.init(name: "Verify libraries")))
            try await verifyPaths(classPaths)
            notify(.step(.init(name: "Verify game profile")))
            try await verifyPath(profilePath.string)
            notify(.step(.init(name: "Verify assets directory")))
            try await verifyPath(assetsPath.string)
        }

        let argumentValues: LaunchArgValueCollection = [
            .authPlayerName: player.username,
            .versionName: fullVersion,
            .gameDirectory: ensureQuotes(profilePath.string),
            .assetsRoot: ensureQuotes(assetsPath.string),
            .assetsIndexName: metaConfig.assetIndex.id,
            .authUUID: player.id.flatUUIDString,
            .uuid: player.id.flatUUIDString,
            .authAccessToken: accessToken,
            .accessToken: accessToken,
            .clientId: ensureQuotes("clientid"), // --clientId ${clientid}    base64 encoded uuid from clientId.txt in .minecraft. Launcher seems to generate a new uuid on every install if the file is not present. (might be a random uuid every install?) @TODO find out more    Optional, send in Telemetry
            .authXUID: ensureQuotes("authxuid"), // --xuid ${auth_xuid}    signerId in the JWT payload returned by the api.minecraftservices.com/entitlements/mcstore endpoint    Optional, send in Telemetry
            .userType: player.lauchUserType,
            .versionType: profile.gameVersion.versionType,
            .resolutionWidth: resolutionSize.width,
            .resolutionHeight: resolutionSize.height,
            .nativesDirectory: nativesPath.string, // the jvm args will be applied with quotes so we don't need it here
            .launcherName: LaunchManager.launcherName,
            .launcherVersion: LaunchManager.launcherVersion,
            .classpath: ensureQuotes(
                classPaths.joined(separator: ":")
            ),
        ]

        let plainArgumentValues = argumentValues.plainArugments()

        let jvmArgs = composeArgs(
            from: metaConfig.arguments.jvm,
            argValues: plainArgumentValues,
            features: LaunchManager.defaultLaunchFeatures,
            patches: composeJVMArgPatches(from: gameSettings),
            shouldEnsureQuotes: true
        )
        let gameArgs = composeArgs(
            from: metaConfig.arguments.game,
            argValues: plainArgumentValues,
            features: LaunchManager.defaultLaunchFeatures,
            patches: composeGameArgPatches(from: gameSettings)
        )

        let mainClass = metaConfig.mainClass
        let cdGameProfileDir = "cd \(ensureQuotes(profilePath.string))\n"
        let javaLaunchScript =
            "\(cdGameProfileDir)\(javaPath) \(jvmArgs) \(mainClass) \(gameArgs)"

        if case .normal = gameSettings.processPriority {
            return javaLaunchScript
        } else {
            return
                "nice -n \(gameSettings.processPriority.rawValue) \(javaLaunchScript)"
        }
    }

    func verifyPaths(_ paths: [String]) async throws {
        for path in paths {
            try await verifyPath(path)
        }
    }

    func verifyPath(_ path: String) async throws {
        if !FileManager.default.fileExists(atPath: path) {
            throw LauncherError.verifyFailed(path: path)
        }
    }

    func loadClinetConfig(clientPath: Path) throws -> MinecraftMetadata {
        let data = try Data(contentsOf: clientPath.url.absoluteURL)
        return try JSONDecoder().decode(MinecraftMetadata.self, from: data)
    }

    func composeClassPaths(
        from meta: MinecraftMeta,
        withLibBase libBase: Path,
        withClientJar clientJar: Path,
        features: LaunchFeatureCollection
    ) -> [String] {
        var classPath: [String] = []

        for lib in meta.libraries {
            if let rules = lib.rules {
                if !rules.allSatisfy(by: features) {
                    continue
                }
            }
            let libPath: Path

            if let downloads = lib.downloads {
                let artifact = downloads.artifact
                libPath = libBase / artifact.path
            } else {
                let name = lib.name
                let segments =
                    name
                        .split(separator: ":")
                        .enumerated()
                        .flatMap { index, seg in
                            if index == 0 {
                                return seg.split(separator: ".")
                            } else {
                                return [seg]
                            }
                        }

                let fileNameStem = segments.suffix(2).joined(separator: "-")
                let fileName = "\(fileNameStem).jar"

                let basePath = segments.reduce(libBase) {
                    partialResult, nextSlug in
                    partialResult / nextSlug
                }

                libPath = basePath / fileName
            }

            classPath.append(libPath.string)
        }

        classPath.append(clientJar.string)

        return classPath
    }

    func processStringArgument(
        segments: inout [String],
        argument: String,
        argValues: LaunchPlainArgValueCollection
    ) {
        let trimmed = argument.trimmingCharacters(in: .whitespaces)
        if let start = trimmed.firstIndex(of: "$"),
           let end = trimmed.firstIndex(of: "}"), start < end,
           trimmed[trimmed.index(start, offsetBy: 1)] == "{"
        {
            let keyStart = trimmed.index(start, offsetBy: 2)
            let key = String(trimmed[keyStart ..< end])

            let before = trimmed[..<start]

            let afterStart = trimmed.index(end, offsetBy: 1)
            let after = trimmed[afterStart...]

            if let argValue = argValues[key] {
                segments.append("\(before)\(argValue)\(after)")
                return
            }
        }

        segments.append(argument)
    }

    func processArgument(
        of arg: MinecraftMetaArgumentElement,
        to segments: inout [String],
        argValues: LaunchPlainArgValueCollection,
        features: LaunchFeatureCollection
    ) {
        switch arg {
        case let .string(argStr):
            processStringArgument(
                segments: &segments, argument: argStr,
                argValues: argValues
            )

        case let .complexArgument(complex):
            let ruleSat = complex.rules.allSatisfy(by: features)

            if ruleSat {
                for argStr in complex.value {
                    processStringArgument(
                        segments: &segments, argument: argStr,
                        argValues: argValues
                    )
                }
            }
        }
    }

    func composeArgs(
        from args: [MinecraftMetaArgumentElement]?,
        argValues: LaunchPlainArgValueCollection,
        features: LaunchFeatureCollection,
        patches: LaunchArgPatchCollection,
        shouldEnsureQuotes: Bool = false
    ) -> String {
        var stringSegments = [String]()

        for arg in args ?? [] {
            processArgument(
                of: arg, to: &stringSegments, argValues: argValues,
                features: features
            )
        }

        stringSegments.append(contentsOf: patches)

        if shouldEnsureQuotes {
            stringSegments = stringSegments.map(ensureQuotes)
        }

        return stringSegments.joined(separator: " ")
    }

    func composeGameArgPatches(from settings: GameSettings)
        -> LaunchArgPatchCollection
    {
        var results = LaunchArgPatchCollection()

        // Game Arg Patches
        if case .fullscreen = settings.resolution {
            results.append("--fullscreen")
        }

        return results
    }

    func composeJVMArgPatches(from settings: GameSettings)
        -> LaunchArgPatchCollection
    {
        var results = LaunchArgPatchCollection()

        // dynamic memory cap
        results.append("-Xmx\(settings.dynamicMemory)m")

        results.append(
            contentsOf: settings.advanced.jvm.composeAdditionalJVMArguments()
                .sorted()
        )

        return results
    }

    static let launcherName: String = "CraftPortal"

    static let launcherVersion: String = AppState.appVersion
}
