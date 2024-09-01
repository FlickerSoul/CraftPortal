//
//  GameProfile+.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//

extension GameProfile {
    static func from(name: String, fullMeta: MinecraftMeta, directory: GameDirectory) -> GameProfile? {
        let versionString = fullMeta.mcVersion ?? fullMeta.id

        guard let gameVersion = GameVersion(type: fullMeta.type, version: versionString) else { return nil }

        let modLoader = ModLoader.fromFullMeta(fullMeta)

        let profile: GameProfile = .init(name: name, gameVersion: gameVersion, modLoader: modLoader, gameDirectory: directory)

        return profile
    }
}
