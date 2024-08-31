//
//  V1.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import SwiftData

// MARK: - V1 Schema

enum CraftPortalSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [PlayerProfile.self, GameDirectory.self, GameProfile.self]
    }
}

typealias LatestSchema = CraftPortalSchemaV1
