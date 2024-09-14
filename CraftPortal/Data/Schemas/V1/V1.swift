//
//  V1.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import SwiftData

// MARK: - V1 Schema

enum CraftPortalSchemaV1: VersionedSchema {
    static let versionIdentifier: Schema.Version = .init(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            PlayerProfile.self,
            GameDirectory.self,
            GameProfile.self,
            GlobalSettings.self,
            GameSettings.self,
            JVMSettings.self,
            AdvancedSettings.self,
            AdvancedJVMSettings.self,
            AdvancedWorkaroundSettings.self,
        ]
    }
}
