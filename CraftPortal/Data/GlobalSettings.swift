//
//  GlobalSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/27/24.
//
import Foundation
import Path

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
        case _currentGameDirectory = "currentGameDirectory"
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

    func addDirectory(
        withURL url: URL, type _: GameDirectoryType, setAsCurrent: Bool = false,
        discoverProfile: Bool = false
    ) {
        guard let path = Path(url.path(percentEncoded: false)) else {
            return
        }

        let newDir = GameDirectory(path: path, directoryType: .Profile)
        settings.gameDirectories.append(newDir)
        saveSettings()

        if setAsCurrent {
            setCurrentGameDirectory(to: newDir)
        }

        if discoverProfile {
            // TODO: discover profile
        }
    }

    func removeDirectory(at index: Int) {
        settings.gameDirectories.remove(at: index)
        saveSettings()
    }

    var currentGameDirectory: GameDirectory? {
        settings.currentGameDirectory
    }

    func setCurrentGameDirectory(to directory: GameDirectory) {
        settings.currentGameDirectory = directory
        saveSettings()
    }

    init(settings: GlobalSettings? = nil) {
        self.settings = settings ?? .init()
    }

    func change<T>(
        keyPath: WritableKeyPath<GlobalSettings, T>, value: T
    ) {
        settings[keyPath: keyPath] = value
        saveSettings()
    }

    func setSettings(with settings: GlobalSettings) {
        self.settings = settings
    }

    func saveSettings() {
        UserDefaults.standard.set(
            try? JSONEncoder().encode(settings),
            forKey: GlobalSettingsManager.settingsPersistenceKey
        )
    }

    static func loadSettings() -> GlobalSettings? {
        return try? JSONDecoder().decode(
            GlobalSettings.self,
            from: UserDefaults.standard.data(forKey: settingsPersistenceKey)
                ?? Data()
        )
    }
}
