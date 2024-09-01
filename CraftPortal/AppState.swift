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

    let appVersion = {
        let version =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return "\(version ?? "Unknown") (\(build ?? "Unknown"))"
    }()

    init(currentUserProfile: PlayerProfile? = nil) {
        self.currentUserProfile = currentUserProfile
        launchManager = LaunchManager()
        jvmManager = JVMManager()

        launchManager.setAppState(self)
    }

    func initializeState() {
        DispatchQueue.global().async {
            let infos = JVMManager.load()
//            let loadedSettings =
//                GlobalSettingsManager.loadSettings()
//
//            let globalSettings = loadedSettings ?? GlobalSettings()
//
//            if loadedSettings == nil {
//                // select JVM if none is present
//                if globalSettings.jvmSettings.selectedJVM == nil
//                    || !infos.contains(globalSettings.jvmSettings.selectedJVM!)
//                {
//                    globalSettings.jvmSettings.selectedJVM = infos.first
//                }
//
//                // discover game directories
//                if globalSettings.gameDirectories.isEmpty {
//                    if let applicationSupport = FileManager.default.urls(
//                        for: .applicationSupportDirectory, in: .userDomainMask
//                    ).first {
//                        if let minecraftPath =
//                            Path(applicationSupport.appendingPathComponent("minecraft", isDirectory: true).path(percentEncoded: false)),
//                            minecraftPath.exists
//                        {
//                            globalSettings.gameDirectories.append(
//                                GameDirectory(
//                                    path: minecraftPath.string, directoryType: .Mangled
//                                ))
//                        }
//
//                        if let applicationPath = Path(
//                            applicationSupport.appendingPathComponent(APP_NAME, isDirectory: true).path(percentEncoded: false)),
//                            applicationPath.exists
//                            || (try? applicationPath.mkdir()) != nil
//                        {
//                            globalSettings.gameDirectories.append(
//                                GameDirectory(
//                                    path: applicationPath.string, directoryType: .Profile
//                                )
//                            )
//                        }
//                    }
//                }
//            } else {
//                if let currentJVM = globalSettings.jvmSettings.selectedJVM, !infos.contains(currentJVM) {
//                    globalSettings.jvmSettings.selectedJVM = nil
//                }
//            }

            DispatchQueue.main.async {
                self.jvmManager.update(with: infos)
//                self.globalSettingsManager.setSettings(with: globalSettings)

                self.initialized = true
            }
        }
    }
}
