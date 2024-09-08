//
//  GameProfile.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import Foundation
import Path
import SwiftData

// MARK: - GameProfile

extension CraftPortalSchemaV1 {
    @Model
    class GameProfile: Identifiable, Codable, FullVersion, ObservableObject {
        static let defaultProfilePicture = "Crafting_Table"

        #Unique<GameProfile>([\._gameDirectory, \.name])

        @Attribute(.unique) var id: UUID
        var name: String // TODO: how to do unique together...
        var gameVersion: GameVersion
        var modLoader: ModLoader?
        var _gameDirectory: GameDirectory?
        var perGameSettingsOn: Bool
        var lastPlayed: Date?
        var profilePicture: String = defaultProfilePicture

        @Relationship(deleteRule: .cascade)
        var gameSettings: GameSettings

        @Transient
        var gameDirectory: GameDirectory {
            get {
                return _gameDirectory!
            }

            set {
                _gameDirectory = newValue
            }
        }

        init(
            id: UUID = UUID(),
            name: String,
            gameVersion: GameVersion,
            modLoader: ModLoader?,
            gameDirectory: GameDirectory? = nil,
            perGameSettingsOn: Bool = false
        ) {
            self.id = id
            self.name = name
            self.gameVersion = gameVersion
            self.modLoader = modLoader
            _gameDirectory = gameDirectory
            self.perGameSettingsOn = perGameSettingsOn
            gameSettings = .init()
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
            _gameDirectory = try container.decode(
                GameDirectory.self, forKey: .gameDirectory
            )
            perGameSettingsOn = try container.decode(
                Bool.self, forKey: .perGameSettingsOn
            )
            gameSettings = try container.decode(
                GameSettings.self, forKey: .gameSettings
            )
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(gameVersion, forKey: .gameVersion)
            try container.encode(modLoader, forKey: .modLoader)
            try container.encode(gameDirectory, forKey: .gameDirectory)
            try container.encode(perGameSettingsOn, forKey: .perGameSettingsOn)
            try container.encode(gameSettings, forKey: .gameSettings)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case gameVersion
            case modLoader
            case gameDirectory
            case perGameSettingsOn
            case gameSettings
        }

        var fullVersion: String {
            switch gameDirectory.directoryType {
            case .Mangled:
                return name
            case .Profile:
                var version = gameVersion.fullVersion
                if let modVersion = modLoader?.fullVersion {
                    version += "-" + modVersion
                }
                return version
            }
        }

        static let profileDirectoryName: String = "profiles"

        func getProfilePath() -> Path {
            switch gameDirectory.directoryType {
            case .Mangled:
                return Path(gameDirectory.path)!
            case .Profile:
                return Path(gameDirectory.path)!
                    / GameProfile.profileDirectoryName / name
            }
        }

        func getProfileToDeletePath() -> Path {
            switch gameDirectory.directoryType {
            case .Mangled:
                return Path(gameDirectory.path)! / "versions" / name
            case .Profile:
                return Path(gameDirectory.path)!
                    / GameProfile.profileDirectoryName / name
            }
        }

        func getSavesPath() -> Path {
            getProfilePath() / "saves"
        }

        func getModsPath() -> Path {
            getProfilePath() / "mods"
        }
    }
}
