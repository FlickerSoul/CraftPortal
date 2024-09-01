//
//  GameProfile.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import Foundation
import Path
import SwiftData

typealias GameProfile = LatestSchema.GameProfile

// MARK: - GameProfile

extension CraftPortalSchemaV1 {
    @Model
    class GameProfile: Identifiable, Codable, FullVersion {
        @Attribute(.unique) var id: UUID
        var name: String // TODO: how to do unique together...
        var gameVersion: GameVersion
        var modLoader: ModLoader?
        var gameDirectory: GameDirectory
        var perGameSettingsOn: Bool

        init(
            id: UUID = UUID(),
            name: String,
            gameVersion: GameVersion,
            modLoader: ModLoader?,
            gameDirectory: GameDirectory,
            perGameSettingsOn: Bool = false
        ) {
            self.id = id
            self.name = name
            self.gameVersion = gameVersion
            self.modLoader = modLoader
            self.gameDirectory = gameDirectory
            self.perGameSettingsOn = perGameSettingsOn
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            gameVersion = try container.decode(
                GameVersion.self, forKey: .gameVersion
            )
            modLoader = try container.decodeIfPresent(
                ModLoader.self, forKey: .modLoader
            )
            gameDirectory = try container.decode(
                GameDirectory.self, forKey: .gameDirectory
            )
            perGameSettingsOn = try container.decode(Bool.self, forKey: .perGameSettingsOn)
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(gameVersion, forKey: .gameVersion)
            try container.encode(modLoader, forKey: .modLoader)
            try container.encode(gameDirectory, forKey: .gameDirectory)
            try container.encode(perGameSettingsOn, forKey: .perGameSettingsOn)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case gameVersion
            case modLoader
            case gameDirectory
            case perGameSettingsOn
        }

        var fullVersion: String {
            return gameVersion.fullVersion + (modLoader?.fullVersion ?? "")
        }

        static let profileDirectoryName: String = "profiles"

        func getProfilePath() -> Path {
            switch gameDirectory.directoryType {
            case .Mangled:
                return Path(gameDirectory.path)!
            case .Profile:
                return Path(gameDirectory.path)! / GameProfile.profileDirectoryName / name
            }
        }
    }
}
