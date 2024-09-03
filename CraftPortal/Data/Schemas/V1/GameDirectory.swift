//
//  GameDirectory.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import Foundation
import Path
import SwiftData

// MARK: - GameDirectory

extension CraftPortalSchemaV1 {
    @Model
    class GameDirectory: Identifiable, Codable, ObservableObject {
        @Attribute(.unique) var id: UUID
        @Attribute(.unique) var path: String
        @Relationship(deleteRule: .cascade, inverse: \GameProfile.gameDirectory)
        var gameProfiles: [GameProfile] = []
        var selectedGame: GameProfile?
        var directoryType: GameDirectoryType
        var belongsTo: GlobalSettings?

        init(
            id: UUID = UUID(),
            path: String,
            directoryType: GameDirectoryType
        ) {
            self.id = id
            self.path = path
            self.directoryType = directoryType
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            path = try container.decode(String.self, forKey: .directory)
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

        func addGames(_ games: [GameProfile]) {
            // TODO: we don't really need it??
            _$observationRegistrar.willSet(self, keyPath: \.gameProfiles)
            gameProfiles.append(contentsOf: games)
        }

        static let metaDirectoryName = "meta"
        func getMetaPath() -> Path {
            switch directoryType {
            case .Mangled:
                return Path(path)!
            case .Profile:
                return Path(path)! / GameDirectory.metaDirectoryName
            }
        }
    }
}
