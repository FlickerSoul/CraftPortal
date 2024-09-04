//
//  GlobalSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/27/24.
//
import Foundation
import Path
import SwiftData

enum SelectedJVM: Codable, Equatable, Hashable {
    case automatic
    case manual(JVMInformation)

    var formattedVersion: String {
        switch self {
        case .automatic:
            return "Automatic"
        case let .manual(jvm):
            return jvm.version
        }
    }

    var formattedPath: String {
        switch self {
        case .automatic:
            return "automatic"
        case let .manual(jvm):
            return jvm.path
        }
    }
}

extension CraftPortalSchemaV1 {
    @Model
    class GlobalSettings: Codable, ObservableObject {
        var gameSettings: GameSettings
        var selectedJVM: SelectedJVM
        var currentGameDirectory: GameDirectory?
        var currentPlayerProfile: PlayerProfile?

        var currentGameProfile: GameProfile? {
            get {
                access(
                    keyPath: \.currentGameDirectory?.selectedGame
                )
                return currentGameDirectory?.selectedGame
            }
            set {
                _$observationRegistrar.willSet(
                    self, keyPath: \.currentGameDirectory?.selectedGame
                )
                currentGameDirectory?.selectedGame = newValue
            }
        }

        var currentGameProfiles: [GameProfile] {
            get {
                access(keyPath: \.currentGameDirectory?.gameProfiles)
                return currentGameDirectory?.gameProfiles ?? []
            }
            set {
                _$observationRegistrar.willSet(
                    self, keyPath: \.currentGameDirectory?.gameProfiles
                )
                currentGameDirectory?.gameProfiles = newValue
            }
        }

        init(
            globalGameSettings: GameSettings = .init(),
            selectedJVM: SelectedJVM = .automatic,
            currentGameDirectory: GameDirectory? = nil,
            currentPlayerProfile: PlayerProfile? = nil
        ) {
            gameSettings = globalGameSettings
            self.selectedJVM = selectedJVM
            self.currentGameDirectory = currentGameDirectory
            self.currentPlayerProfile = currentPlayerProfile
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            gameSettings = try container.decode(
                GameSettings.self, forKey: ._gameSettings
            )
            selectedJVM = try container.decode(
                SelectedJVM.self, forKey: ._selectedJVM
            )
            currentGameDirectory = try container.decode(
                GameDirectory.self, forKey: ._currentGameDirectory
            )
            currentPlayerProfile = try container.decode(
                PlayerProfile.self, forKey: ._currentPlayerProfile
            )
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(gameSettings, forKey: ._gameSettings)
            try container.encode(selectedJVM, forKey: ._selectedJVM)
            try container.encode(
                currentGameDirectory, forKey: ._currentGameDirectory
            )
            try container.encode(
                currentPlayerProfile, forKey: ._currentPlayerProfile
            )
        }

        enum CodingKeys: String, CodingKey {
            case _gameSettings = "gameSettings"
            case _selectedJVM = "selectedJVM"
            case _currentGameDirectory = "currentGameDirectory"
            case _currentPlayerProfile = "currentPlayerProfile"
        }
    }
}
