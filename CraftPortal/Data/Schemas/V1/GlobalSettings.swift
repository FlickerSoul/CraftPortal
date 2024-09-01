//
//  GlobalSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/27/24.
//
import Foundation
import Path
import SwiftData

extension CraftPortalSchemaV1 {
    @Model
    class GlobalSettings: Codable {
        var gameSettings: GameSettings
        var jvmSettings: JVMSettings
        var currentGameDirectory: GameDirectory?
        var currentPlayerProfile: PlayerProfile?

        init(
            globalGameSettings: GameSettings = .init(),
            jvmSettings: JVMSettings = .init(),
            currentGameDirectory: GameDirectory? = nil,
            currentPlayerProfile: PlayerProfile? = nil
        ) {
            gameSettings = globalGameSettings
            self.jvmSettings = jvmSettings
            self.currentGameDirectory = currentGameDirectory
            self.currentPlayerProfile = currentPlayerProfile
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            gameSettings = try container.decode(GameSettings.self, forKey: ._globalGameSettings)
            jvmSettings = try container.decode(JVMSettings.self, forKey: ._jvmSettings)
            currentGameDirectory = try container.decode(GameDirectory.self, forKey: ._currentGameDirectory)
            currentPlayerProfile = try container.decode(PlayerProfile.self, forKey: ._currentPlayerProfile)
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(gameSettings, forKey: ._globalGameSettings)
            try container.encode(jvmSettings, forKey: ._jvmSettings)
            try container.encode(currentGameDirectory, forKey: ._jvmSettings)
            try container.encode(currentPlayerProfile, forKey: ._currentPlayerProfile)
        }

        enum CodingKeys: String, CodingKey {
            case _globalGameSettings = "globalGameSettings"
            case _jvmSettings = "jvmSettings"
            case _currentGameDirectory = "currentGameDirectory"
            case _currentPlayerProfile = "currentPlayerProfile"
        }
    }
}
