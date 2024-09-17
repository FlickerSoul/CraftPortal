//
//  LaunchButtonModifier.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/15/24.
//

import SwiftUI

private struct LaunchButtonModifier: ViewModifier {
    let appState: AppState
    let globalSettings: GlobalSettings
    let openWindow: OpenWindowAction
    let failedCallback: (() -> Void)?
    let gameProfile: GameProfile?
    @Binding var showLaunchWarning: Bool
    @Binding var showLaunch: Bool

    init(
        appState: AppState, globalSettings: GlobalSettings,
        openWindow: OpenWindowAction,
        showLaunchWarning: Binding<Bool>,
        showLaunch: Binding<Bool>,
        failedCallback: (() -> Void)? = nil,
        gameProfile: GameProfile? = nil
    ) {
        self.appState = appState
        self.globalSettings = globalSettings
        self.openWindow = openWindow
        _showLaunchWarning = showLaunchWarning
        _showLaunch = showLaunch
        self.failedCallback = failedCallback
        self.gameProfile = gameProfile
    }

    func body(content: Content) -> some View {
        content
            .hoverCursor()
            .sheet(
                isPresented: $showLaunchWarning,
                content: {
                    if let profile = globalSettings.currentPlayerProfile {
                        LaunchStatusMultiInstanceWarning(
                            username: profile.username)
                    }
                }
            )
            .sheet(
                isPresented: $showLaunch,
                content: {
                    LaunchStatusInfoView(inWindow: false)
                }
            )
            .onTapGesture {
                if let profile = gameProfile
                    ?? globalSettings.currentGameProfile
                {
                    if let uuid = globalSettings.currentPlayerProfile?.id,
                       !appState.launchManager.noProcessRunning(for: uuid)
                    {
                        showLaunchWarning = true
                        return
                    }

                    let showLogs =
                        profile.perGameSettingsOn
                            ? profile.gameSettings.showLogs
                            : globalSettings.gameSettings.showLogs

                    if showLogs {
                        openWindow(id: "launch-logs", value: profile.id)
                    } else {
                        showLaunch = true
                    }
                } else {
                    if let failedCallback {
                        failedCallback()
                    } else {
                        appState.setError(title: "Internal State Error", description: "Cannot find a game profile or backup action when lauching. This is an internal error. Please contact the developer.")
                    }
                }
            }
    }
}

extension View {
    func asLaunchButton(
        appState: AppState, globalSettings: GlobalSettings,
        openWindow: OpenWindowAction,
        showLaunchWarning: Binding<Bool>,
        showLaunch: Binding<Bool>,
        failedCallback: (() -> Void)? = nil,
        gameProfile: GameProfile? = nil
    ) -> some View {
        modifier(
            LaunchButtonModifier(
                appState: appState, globalSettings: globalSettings,
                openWindow: openWindow, showLaunchWarning: showLaunchWarning,
                showLaunch: showLaunch, failedCallback: failedCallback,
                gameProfile: gameProfile
            ))
    }
}
