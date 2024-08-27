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
}

class LaunchManager {
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
            let script = try composeLaunchScript(
                player: player, profile: profile
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

    func composeLaunchScript(player: PlayerProfile, profile: GameProfile) throws
        -> String
    {
        let gameDir = profile.gameDirectory
        let gameDirPath = profile.gameDirectory.path
        let fullVersion = profile.fullVersion

        let metaPath: Path = {
            switch gameDir.directoryType {
            case .Mangled:
                return gameDirPath
            case .Profile:
                return gameDirPath / "meta"
            }
        }()

        let libraryPath = metaPath / "libraries"
        let assetsPath = metaPath / "assets"
        let nativesPath = metaPath / "natives" / fullVersion

        let clientLocation = metaPath / "versions" / fullVersion
        let clientJarPath = clientLocation / "\(fullVersion).jar"
        let clientConfigPath = clientLocation / "\(fullVersion).json"

        let profilePath: Path = {
            switch gameDir.directoryType {
            case .Mangled:
                return gameDirPath
            case .Profile:
                return gameDirPath / "profiles" / profile.name
            }
        }()

        let metaConfig = try loadClinetConfig(clientPath: clientConfigPath)
        let launchFeatures: LaunchFeatureCollection = [:] // TODO: make features

        let argumentValues: LaunchArgValueCollection = [
            .authPlayerName: player.username,
            .versionName: fullVersion,
            .gameDirectory: profilePath.string,
            .assetsRoot: assetsPath.string,
            .assetsIndexName: metaConfig.assetIndex.id,
            .authUUID: player.id.flatUUIDString,
            .authAccessToken: "", // TODO: player auth
            .clientId: "", // hmmm
            .authXUID: "", // hmmm
            .userType: player.userType,
            .versionType: profile.gameVersion.versionType,
            .resolutionWidth: "", // TODO: add later with settings
            .resolutionHeight: "", // TODO: add later with settings
            .nativesDirectory: nativesPath.string,
            .launcherName: launcherName,
            .launcherVersion: launcherVersion,
            .classpath: composeClassPaths(
                from: metaConfig, withLibBase: libraryPath,
                withClientJar: clientJarPath,
                features: launchFeatures
            ),
        ]

        let plainArgumentValues = argumentValues.plainArugments()

        let jvmArgs = composeArgs(
            from: metaConfig.arguments.jvm,
            argValues: plainArgumentValues,
            features: launchFeatures,
            patches: composeArgumentPatches(from: profile)
        )
        let gameArgs = composeArgs(
            from: metaConfig.arguments.game,
            argValues: plainArgumentValues,
            features: [:], // TODO: make features
            patches: composeArgumentPatches(from: profile)
        )

        let javaPath = getJavaPath()
        let mainClass = metaConfig.mainClass

        return "\(javaPath) \(jvmArgs) \(mainClass) \(gameArgs)"
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

    func getJavaPath() -> String {
        // TODO: load java path from settings
        return Path("~/.jenv/shims/java")!.string
    }

    func processStringArgument(
        segments: inout [String],
        argument: String,
        argValues: LaunchPlainArgValueCollection
    ) {
        let trimmed = argument.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("${"), trimmed.hasSuffix("}") {
            let start = trimmed.index(
                trimmed.startIndex, offsetBy: 2
            )
            let end = trimmed.index(trimmed.endIndex, offsetBy: -1)

            let sliced = String(trimmed[start ..< end])

            if let argValue = argValues[sliced] {
                segments.append(argValue)
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
        patches: LaunchArgPatchCollection
    ) -> String {
        var stringSegments = [String]()

        for arg in args ?? [] {
            processArgument(
                of: arg, to: &stringSegments, argValues: argValues,
                features: features
            )
        }

        stringSegments.append(contentsOf: patches)

        return stringSegments.joined(separator: " ")
    }

    func composeArgumentPatches(from _: GameProfile)
        -> LaunchArgPatchCollection
    {
        // TODO: make custom arguments
        return []
    }

    var launcherName: String {
        return "CraftPortal"
    }

    var launcherVersion: String {
        return appState?.appVersion ?? "unknown"
    }
}
