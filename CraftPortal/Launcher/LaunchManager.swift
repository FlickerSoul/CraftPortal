//
//  LaunchManager.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import Foundation
import Path

enum LaunchArguments: String, Equatable, Hashable {
    case authPlayerName = "auth_player_name"
    case versionName = "version_name"
    case gameDirectory = "game_directory"
    case assetsRoot = "assets_root"
    case assetsIndexName = "assets_index_name"
    case authUUID = "auth_uuid"
    case authAccessToken = "auth_access_token"
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

private let SHELL_EXECUTABLE = "/bin/sh"

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

enum LauncherError: Error {
    case noShellExecutable
    case launchFailed
    case noJVM
}

private func ensureQuotes(_ value: String) -> String {
    return value.hasPrefix("\"") && value.hasSuffix("\"")
        ? value : "\"\(value)\""
}

class LaunchManager {
    static let defaultLaunchFeatures: LaunchFeatureCollection = [
        "has_custom_resolution": true,
    ]

    weak var appState: AppState?
    private(set) var launcherState: LauncherState = .idle

    func setAppState(_ appState: AppState) {
        self.appState = appState
    }

    func toggleLauncherState(_ state: LauncherState) {
        launcherState = state
    }

    func launch(profile: GameProfile? = nil) {
        // TODO: logging lauching failed
        if launcherState != .idle { return }

        toggleLauncherState(.idle)

        guard let profile = profile ?? appState?.currentGameProfile else {
            toggleLauncherState(.idle)
            return
        }
        guard let player = appState?.currentUserProfile else {
            toggleLauncherState(.idle)
            return
        }

        do {
            guard
                let javaPath = appState?.globalSettingsManager.jvmSettings
                .selectedJVM?.path
            else {
                throw LauncherError.noJVM
            }

            let script = try composeLaunchScript(
                player: player, profile: profile,
                javaPath: javaPath
            )
            _ = try executeScript(script)
        } catch {}

        toggleLauncherState(.idle)
    }

    func executeScript(
        _ script: String, shellExecutable: String = SHELL_EXECUTABLE
    ) throws -> Process {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: shellExecutable) {
            throw LauncherError.noShellExecutable
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: shellExecutable)
        process.arguments = ["-c", script]
        process.qualityOfService = .userInteractive

        // TODO: pipe the logs
        process.standardOutput = nil
        process.standardError = nil
        process.standardInput = nil

        do {
            try process.run()
            print("Process running \(process.processIdentifier)")
        } catch {
            throw LauncherError.launchFailed
        }

        return process
    }

    func composeLaunchScript(
        player: PlayerProfile, profile: GameProfile, javaPath: String
    ) throws
        -> String
    {
        let javaPath = ensureQuotes(javaPath)

        let gameDir = profile.gameDirectory
        let gameDirPath = profile.gameDirectory.path
        let fullVersion = profile.fullVersion

        let metaPath: Path = gameDir.getMetaPath()

        let libraryPath = metaPath / "libraries"
        let assetsPath = metaPath / "assets"
        let nativesPath = metaPath / "natives" / fullVersion

        let clientLocation = metaPath / "versions" / fullVersion
        let clientJarPath = clientLocation / "\(fullVersion).jar"
        let clientConfigPath = clientLocation / "\(fullVersion).json"

        let profilePath: Path = profile.getProfilePath()

        let metaConfig = try loadClinetConfig(clientPath: clientConfigPath)
        let gameSettings =
            appState?.globalSettingsManager.globalGameSettings
                ?? .init() // TODO: huhhhh
        // TODO: per game settings loading

        let argumentValues: LaunchArgValueCollection = {
            let resolutionSize = gameSettings.resolution.toSizeStrings()

            return [
                .authPlayerName: player.username,
                .versionName: fullVersion,
                .gameDirectory: ensureQuotes(profilePath.string),
                .assetsRoot: ensureQuotes(assetsPath.string),
                .assetsIndexName: metaConfig.assetIndex.id,
                .authUUID: player.id.flatUUIDString,
                .authAccessToken: player.getAccessToken(),
                .clientId: ensureQuotes("clientid"), // TODO: hmmm
                .authXUID: ensureQuotes("authxuid"), // TODO: hmmm
                .userType: player.userType,
                .versionType: profile.gameVersion.versionType,
                .resolutionWidth: resolutionSize.width,
                .resolutionHeight: resolutionSize.height,
                .nativesDirectory: nativesPath.string, // the jvm args will be applied with quotes so we don't need it here
                .launcherName: launcherName,
                .launcherVersion: launcherVersion,
                .classpath: ensureQuotes(
                    composeClassPaths(
                        from: metaConfig,
                        withLibBase: libraryPath,
                        withClientJar: clientJarPath,
                        features: LaunchManager.defaultLaunchFeatures
                    )
                ),
            ]
        }()

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
        let javaLaunchScript = "\(javaPath) \(jvmArgs) \(mainClass) \(gameArgs)"

        if case .normal = gameSettings.processPriority {
            return javaLaunchScript
        } else {
            return
                "nice -n \(gameSettings.processPriority.rawValue) \(javaLaunchScript)"
        }
    }

    func loadClinetConfig(clientPath: Path) throws -> MinecraftMeta {
        let data = try Data(contentsOf: clientPath.url.absoluteURL)
        return try JSONDecoder().decode(MinecraftMeta.self, from: data)
    }

    func composeClassPaths(
        from meta: MinecraftMeta,
        withLibBase libBase: Path,
        withClientJar clientJar: Path,
        features: LaunchFeatureCollection
    ) -> String {
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

        return classPath.joined(separator: ":")
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
            contentsOf: settings.advanced.jvm.composeAdditionalJVMArguments().sorted()
        )

        return results
    }

    var launcherName: String {
        return "CraftPortal"
    }

    var launcherVersion: String {
        return appState?.appVersion ?? "unknown"
    }
}
