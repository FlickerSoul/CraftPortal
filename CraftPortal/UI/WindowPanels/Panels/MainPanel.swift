//
//  MainPanel.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//

import Path
import SwiftData
import SwiftUI
import SwiftUICore

struct MainPanel: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var globalSettings: GlobalSettings
    @Environment(\.openWindow) private var openWindow
    @State private var showLaunchWarning = false
    @State private var showLaunch = false

    let updatePanel: (FunctionPanel) -> Void

    var noGameSelected: Bool {
        globalSettings.currentGameProfile == nil
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()

                launchButton
            }
            .padding(32)
        }
    }

    @ViewBuilder
    private var launchButton: some View {
        ZStack {
            if noGameSelected {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 200, height: 80)
                    .foregroundStyle(.gray.opacity(0.8))
            }

            FrostGlassEffect(material: .hudWindow, blendingMode: .withinWindow)
                .clipShape(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .frame(width: 200, height: 80)
        }
        .overlay {
            VStack {
                if let selectegameProfile = globalSettings.currentGameProfile {
                    Text("Launch Game")
                        .font(.headline)
                    Text(selectegameProfile.name)
                        .font(.subheadline)
                } else {
                    Text("No Game Selected")
                        .font(.headline)
                    Text("Go To Game Library")
                        .font(.subheadline)
                }
            }
        }
        .hoverCursor()
        .sheet(
            isPresented: $showLaunchWarning, // TODO: decouple this
            content: {
                if let profile = globalSettings.currentPlayerProfile {
                    LaunchStatusMultiInstanceWarning(username: profile.username)
                }
            }
        )
        .sheet(isPresented: $showLaunch, content: {
            LaunchStatusInfoView(inWindow: false)
        })
        .onTapGesture {
            if noGameSelected {
                updatePanel(.GameLibrary)
            } else {
                if let uuid = globalSettings.currentPlayerProfile?.id, !appState.launchManager.noProcessRunning(for: uuid) {
                    showLaunchWarning = true
                    return
                }

                if globalSettings.gameSettings.showLogs {
                    openWindow(id: "launch-logs")
                } else {
                    showLaunch = true
                }
            }
        }
    }

    private func tryLaunch() {}
}

#Preview("no game profile") {
    VStack {
        MainPanel { _ in }
    }
    .background(Image("HomeBackground2"))
}
