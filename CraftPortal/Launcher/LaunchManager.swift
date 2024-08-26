//
//  LaunchManager.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import Foundation
import Path

class LaunchManager {
    weak var appState: AppState?

    func setAppState(_ appState: AppState) {
        self.appState = appState
    }

    func launch(profile: GameProfile? = nil) {
        // TODO: logging lauching failed
        guard let profile = profile ?? appState?.currentGameProfile else { return }

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
        let clientLocation = metaPath / "versions" / fullVersion
        let clientPath = clientLocation / "\(fullVersion).jar"
        let clientConfig = clientLocation / "\(fullVersion).json"

        let profilePath: Path = {
            switch gameDir.directoryType {
            case .Mangled:
                return gameDirPath
            case .Profile:
                return gameDirPath / "profiles" / profile.name
            }
        }()
    }

    func loadClinetConfig(clientPath: Path) -> MinecraftMeta? {
        let data = try? Data(contentsOf: clientPath.url.absoluteURL)
        guard let data else { return nil }

        let decoder = JSONDecoder()
        return try? decoder.decode(MinecraftMeta.self, from: data)
    }
}
