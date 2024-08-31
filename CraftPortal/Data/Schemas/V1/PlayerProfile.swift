//
//  PlayerProfile.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import Foundation
import SwiftData

typealias PlayerProfile = LatestSchema.PlayerProfile

// MARK: - UserProfile Model

extension CraftPortalSchemaV1 {
    @Model
    class PlayerProfile: Identifiable, Codable {
        @Attribute(.unique) var id: UUID
        @Attribute(.unique) var username: String
        var playerType: UserAccountType

        init(id: UUID, username: String, playerType: UserAccountType) {
            self.id = id
            self.username = username
            self.playerType = playerType
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            username = try container.decode(String.self, forKey: .username)
            playerType = try container.decode(
                UserAccountType.self, forKey: .accountType
            )
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(username, forKey: .username)
            try container.encode(playerType, forKey: .accountType)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case username
            case accountType
        }

        var userType: String {
            return "msa"
        }

        func getAccessToken() -> String {
            // TODO: link with auth
            // TODO: maybe do it with the auth manager so that you get token refresh
            return id.flatUUIDString
        }
    }
}
