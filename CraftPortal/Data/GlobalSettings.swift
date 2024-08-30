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
    var jvmSettings: JVMSettings

    init(
        globalGameSettings: GameSettings = .init(),
        jvmSettings: JVMSettings = .init()
    ) {
        self.globalGameSettings = globalGameSettings
        self.jvmSettings = jvmSettings
    }

    enum CodingKeys: String, CodingKey {
        case _globalGameSettings = "globalGameSettings"
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

    init(settings: GlobalSettings? = nil) {
        self.settings = settings ?? .init()
    }

    func change<T>(keyPath: WritableKeyPath<GlobalSettings, T>, value: T) {
        settings[keyPath: keyPath] = value
        saveSettings()
    }

    func saveSettings() {
        DispatchQueue.global().async {
            UserDefaults.standard.set(
                try? JSONEncoder().encode(self.settings),
                forKey: GlobalSettingsManager.settingsPersistenceKey
            )
        }
    }
}
