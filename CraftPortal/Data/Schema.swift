//
//  Schema.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//
import Foundation
import Path
import SwiftData

// MARK: - AUX

protocol FullVersion {
    var fullVersion: String { get }
}

/// An enum represeting the mod loader used in the game
enum ModLoader: Codable, FullVersion {
    case Forge(major: Int, minor: Int, patch: Int)
    case NeoForge(major: Int, minor: Int, patch: Int)
    case Fabric(major: Int, minor: Int, patch: Int)
    case Quilt(major: Int, minor: Int, patch: Int)

    var fullVersion: String {
        switch self {
        case let .Forge(major, minor, patch):
            return "forge-\(major).\(minor).\(patch)"
        case let .NeoForge(major, minor, patch):
            return "neoforge-\(major).\(minor).\(patch)"
        case let .Fabric(major, minor, patch):
            return "fabric-\(major).\(minor).\(patch)"
        case let .Quilt(major, minor, patch):
            return "quilt-\(major).\(minor).\(patch)"
        }
    }
}

/// An enum represeting the versions of the game
enum GameVersion: Codable, FullVersion {
    case Release(major: Int, minor: Int, patch: Int)
    case Snapshot(version: String)
    case Historical(major: Int, minor: Int, patch: Int)

    var fullVersion: String {
        switch self {
        case let .Release(major, minor, patch):
            return "\(major).\(minor).\(patch)"
        case let .Snapshot(version):
            return version
        case let .Historical(major, minor, patch):
            return "\(major).\(minor).\(patch)"
        }
    }
}

/// An enum representing the user profile type
enum UserAccountType: Codable {
    case Local
    case MSA
}

/// An enum represeting the game directory type: how game directory is structured
enum GameDirectoryType: Codable {
    case Mangled
    case Profile
}

// MARK: - V1 Schema

enum CraftPortalSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [UserProfile.self, GameDirectory.self, GameProfile.self]
    }
}

// MARK: - UserProfile Model

extension CraftPortalSchemaV1 {
    @Model
    class UserProfile: Identifiable, Codable {
        @Attribute(.unique) var id: UUID
        @Attribute(.unique) var username: String
        var accountType: UserAccountType

        init(id: UUID, username: String, accountType: UserAccountType) {
            self.id = id
            self.username = username
            self.accountType = accountType
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            username = try container.decode(String.self, forKey: .username)
            accountType = try container.decode(
                UserAccountType.self, forKey: .accountType
            )
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(username, forKey: .username)
            try container.encode(accountType, forKey: .accountType)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case username
            case accountType
        }
    }
}

// MARK: - GameDirectory

extension CraftPortalSchemaV1 {
    @Model
    class GameDirectory: Identifiable, Codable {
        @Attribute(.unique) var id: UUID
        @Relationship(deleteRule: .cascade, inverse: \GameProfile.gameDirectory)
        var gameProfiles: [GameProfile] = []
        var path: Path
        var selectedGame: GameProfile?
        var directoryType: GameDirectoryType

        init(
            id: UUID = UUID(),
            path: Path,
            directoryType: GameDirectoryType
        ) {
            self.id = id
            self.path = path
            self.directoryType = directoryType
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            path = try container.decode(Path.self, forKey: .directory)
            selectedGame = try container.decodeIfPresent(
                GameProfile.self, forKey: .selectedGame
            )
            directoryType = try container.decode(
                GameDirectoryType.self, forKey: .directoryType
            )
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(path, forKey: .directory)
            try container.encode(selectedGame, forKey: .selectedGame)
            try container.encode(directoryType, forKey: .directoryType)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case directory
            case selectedGame
            case directoryType
        }

        func addAndSelectGame(_ game: GameProfile) {
            let found = gameProfiles.filter { $0.id == game.id }.count > 0
            if !found {
                gameProfiles.append(game)
            }
            selectedGame = game
        }

        func selectGame(_ game: GameProfile) {
            let found = gameProfiles.filter { $0.id == game.id }.count > 0

            if found {
                selectedGame = game
            }
        }
    }
}

// MARK: - GameProfile

extension CraftPortalSchemaV1 {
    @Model
    class GameProfile: Identifiable, Codable, FullVersion {
        @Attribute(.unique) var id: UUID
        @Attribute(.unique) var name: String
        var gameVersion: GameVersion
        var modLoader: ModLoader?
        var gameDirectory: GameDirectory

        init(
            id: UUID = UUID(),
            name: String,
            gameVersion: GameVersion,
            modLoader: ModLoader?,
            gameDirectory: GameDirectory
        ) {
            self.id = id
            self.name = name
            self.gameVersion = gameVersion
            self.modLoader = modLoader
            self.gameDirectory = gameDirectory
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
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(gameVersion, forKey: .gameVersion)
            try container.encode(modLoader, forKey: .modLoader)
            try container.encode(gameDirectory, forKey: .gameDirectory)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case gameVersion
            case modLoader
            case gameDirectory
        }

        var fullVersion: String {
            return gameVersion.fullVersion + (modLoader?.fullVersion ?? "")
        }
    }
}

typealias LatestSchema = CraftPortalSchemaV1
typealias UserProfile = LatestSchema.UserProfile
typealias GameDirectory = LatestSchema.GameDirectory
typealias GameProfile = LatestSchema.GameProfile
