//
//  GameDirectory.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import Foundation
import Path
import SwiftData

typealias GameDirectory = LatestSchema.GameDirectory

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

        static let metaDirectoryName = "meta"
        func getMetaPath() -> Path {
            switch directoryType {
            case .Mangled:
                return path
            case .Profile:
                return path / GameDirectory.metaDirectoryName
            }
        }
    }
}
