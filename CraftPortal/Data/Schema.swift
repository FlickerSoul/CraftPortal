//
//  Schema.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//
import Foundation
import SwiftData

enum CraftPortalSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [UserProfile.self]
    }
}

extension CraftPortalSchemaV1 {
    @Model
    class UserProfile: Identifiable, Codable {
        @Attribute(.unique) var id: UUID
        @Attribute(.unique) var username: String

        init(id: UUID, username: String) {
            self.id = id
            self.username = username
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            username = try container.decode(String.self, forKey: .username)
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(username, forKey: .username)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case username
        }
    }
}

typealias LatestSchema = CraftPortalSchemaV1
typealias UserProfile = LatestSchema.UserProfile
