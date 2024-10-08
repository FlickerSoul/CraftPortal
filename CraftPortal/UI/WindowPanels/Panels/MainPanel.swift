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
        .asLaunchButton(
            appState: appState, globalSettings: globalSettings,
            openWindow: openWindow, showLaunchWarning: $showLaunchWarning,
            showLaunch: $showLaunch,
            failedCallback: {
                updatePanel(.GameLibrary)
            }
        )
    }
}

#Preview("no game profile") {
    VStack {
        MainPanel { _ in }
    }
    .background(Image("HomeBackground2"))
}
