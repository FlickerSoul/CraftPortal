//
//  GlobalSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/27/24.
//
import Foundation

@Observable
class JVMSettings: Codable {
    var selectedJVM: JVMInformation? = nil

    enum CodingKeys: String, CodingKey {
        case _selectedJVM = "selectedJVM"
    }
}

@Observable
class GlobalSettings: Codable {
    var globalGameSettings: GameSettings
    var gameDirectories: [GameDirectory]
    var currentGameDirectory: GameDirectory?
    var jvmSettings: JVMSettings

    init(
        globalGameSettings: GameSettings = .init(),
        jvmSettings: JVMSettings = .init(),
        gameDirectories: [GameDirectory] = [],
        currentGameDirectory: GameDirectory? = nil
    ) {
        self.globalGameSettings = globalGameSettings
        self.jvmSettings = jvmSettings
        self.gameDirectories = gameDirectories
        self.currentGameDirectory = currentGameDirectory
    }

    enum CodingKeys: String, CodingKey {
        case _globalGameSettings = "globalGameSettings"
        case _gameDirectories = "gameDirectories"
        case _jvmSettings = "jvmSettings"
    }
}

@Observable
class GlobalSettingsManager {
    static let settingsPersistenceKey: String = "GlobalSettings"

    private var settings: GlobalSettings {
        didSet {
            saveSettings()
        }
    }

    var globalGameSettings: GameSettings {
        settings.globalGameSettings
    }

    var jvmSettings: JVMSettings {
        settings.jvmSettings
    }

    var gameDirectories: [GameDirectory] {
        settings.gameDirectories
    }

    var currentGameDirectory: GameDirectory? {
        settings.currentGameDirectory
    }

    init(settings: GlobalSettings? = nil) {
        self.settings = settings ?? .init()
    }

    func change<T>(
        keyPath: WritableKeyPath<GlobalSettings, T>, value: T,
        onComplete handle: (() -> Void)? = nil
    ) {
        settings[keyPath: keyPath] = value
        saveSettings(onComplete: handle)
    }

    func setSettings(with settings: GlobalSettings) {
        self.settings = settings
    }

    func saveSettings(onComplete handle: (() -> Void)? = nil) {
        DispatchQueue.global().async {
            UserDefaults.standard.set(
                try? JSONEncoder().encode(self.settings),
                forKey: GlobalSettingsManager.settingsPersistenceKey
            )

            if let handle = handle {
                handle()
            }
        }
    }

    static func loadSettings() -> GlobalSettings? {
        return try? JSONDecoder().decode(
            GlobalSettings.self,
            from: UserDefaults.standard.data(forKey: settingsPersistenceKey)
                ?? Data()
        )
    }
}
