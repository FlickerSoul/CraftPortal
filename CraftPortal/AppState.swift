//
//  AppState.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//
import Foundation
import Path
import SwiftData
import struct SwiftUICore.LocalizedStringKey

final class AppState: ObservableObject {
    private(set) var launchManager: LaunchManager
    @Published private(set) var jvmManager: JVMManager
    @Published private(set) var initialized: Bool = false
    @Published var currentError: ErrorInfo? = nil

    static let appVersion = {
        let version =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return "\(version ?? "Unknown") (\(build ?? "Unknown"))"
    }()

    init() {
        launchManager = LaunchManager()
        jvmManager = JVMManager()
    }

    private static let LAUNCHED_BEFORE_FLAG_KEY: String =
        "CraftPortal.LAUNCHED_BEFORE"

    static let isFirstLaunch: Bool = {
        let result = UserDefaults.standard.bool(
            forKey: AppState.LAUNCHED_BEFORE_FLAG_KEY)

        if !result {
            UserDefaults.standard.set(
                true, forKey: AppState.LAUNCHED_BEFORE_FLAG_KEY
            )
        }

        return !result
    }()

    func initializeState(globalSettings _: GlobalSettings) {
        let infos = JVMManager.load()
        jvmManager.update(with: infos)
    }

    func finishInitialization() {
        initialized = true
    }

    func setError(title: LocalizedStringKey, description: LocalizedStringKey, callback: ErrorCallback? = nil) {
        currentError = .init(title: title, description: description, callback: callback)
    }
}
