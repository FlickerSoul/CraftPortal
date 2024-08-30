//
//  AppState.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//
import Foundation
import SwiftData

final class AppState: ObservableObject {
    @Published var currentUserProfile: PlayerProfile?
    @Published var currentGameDirectory: GameDirectory?
    private(set) var launchManager: LaunchManager
    @Published private(set) var jvmManager: JVMManager
    @Published private(set) var initialized: Bool = false
    @Published private(set) var globalSettingsManager: GlobalSettingsManager

    let appVersion = {
        let version =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return "\(version ?? "Unknown") (\(build ?? "Unknown"))"
    }()

    var currentGameProfile: GameProfile? {
        currentGameDirectory?.selectedGame
    }

    init(
        currentUserProfile: PlayerProfile? = nil,
        currentGameDirectory: GameDirectory? = nil
    ) {
        self.currentUserProfile = currentUserProfile
        self.currentGameDirectory = currentGameDirectory
        launchManager = LaunchManager()
        jvmManager = JVMManager()
        globalSettingsManager = GlobalSettingsManager()

        launchManager.setAppState(self)
    }

    func initializeState() {
        DispatchQueue.global().async {
            let infos = self.jvmManager.discover()
            let globalSettings = GlobalSettingsManager.loadSettings()

            DispatchQueue.main.async {
                self.jvmManager.update(with: infos)
                if let globalSettings = globalSettings {
                    self.globalSettingsManager.updateSettings(with: globalSettings)
                }

                self.initialized = true
            }
        }
    }

    func validateState(container: ModelContainer) {
        validateUserProfile(container: container)
    }

    func validateUserProfile(container: ModelContainer) {
        let context = ModelContext(container)

        // validate usre still exists
        if currentUserProfile != nil {
            let fetchedProfiles = try? context.fetch(
                FetchDescriptor<PlayerProfile>(
                    predicate: #Predicate { userProfile in
                        if let currentUserProfile = currentUserProfile {
                            return currentUserProfile.id == userProfile.id
                        } else {
                            return false
                        }
                    }
                ))

            if fetchedProfiles == nil || fetchedProfiles!.isEmpty {
                currentUserProfile = nil
            }
        }
    }
}
