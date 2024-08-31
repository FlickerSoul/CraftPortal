//
//  AppState.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//
import Foundation
import Path
import SwiftData

final class AppState: ObservableObject {
    @Published var currentUserProfile: PlayerProfile?
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

    var currentGameDirectory: GameDirectory? {
        globalSettingsManager.currentGameDirectory
    }

    var currentGameProfile: GameProfile? {
        currentGameDirectory?.selectedGame
    }

    init(
        currentUserProfile: PlayerProfile? = nil,
        currentGameDirectory _: GameDirectory? = nil
    ) {
        self.currentUserProfile = currentUserProfile
        launchManager = LaunchManager()
        jvmManager = JVMManager()
        globalSettingsManager = GlobalSettingsManager()

        launchManager.setAppState(self)
    }

    func initializeState() {
        DispatchQueue.global().async {
            let infos = JVMManager.load()
            let globalSettings =
                GlobalSettingsManager.loadSettings() ?? GlobalSettings()

            if globalSettings.jvmSettings.selectedJVM == nil
                || !infos.contains(globalSettings.jvmSettings.selectedJVM!)
            {
                globalSettings.jvmSettings.selectedJVM = infos.first
            }

            if globalSettings.gameDirectories.isEmpty {
                if let applicationSupport = FileManager.default.urls(
                    for: .applicationSupportDirectory, in: .userDomainMask
                ).first {
                    if let minecraftPath =
                        Path(applicationSupport.appendingPathComponent("minecraft", isDirectory: true).path(percentEncoded: false)),
                        minecraftPath.exists
                    {
                        globalSettings.gameDirectories.append(
                            GameDirectory(
                                path: minecraftPath, directoryType: .Mangled
                            ))
                    }

                    print("a")
                    if let applicationPath = Path(
                        applicationSupport.appendingPathComponent(APP_NAME, isDirectory: true).path(percentEncoded: false)),
                        applicationPath.exists
                        || (try? applicationPath.mkdir()) != nil
                    {
                        print("b")
                        globalSettings.gameDirectories.append(
                            GameDirectory(
                                path: applicationPath, directoryType: .Profile
                            )
                        )
                    }
                }
            }

            DispatchQueue.main.async {
                self.jvmManager.update(with: infos)
                self.globalSettingsManager.setSettings(with: globalSettings)

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
