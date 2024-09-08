//
//  GameSettingsPanel.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//

import SwiftUI

struct GameSettingsPanelView: View {
    @Binding var isActive: Bool
    @Binding var gameSttings: GameSettings

    var body: some View {
        VStack {
            HStack {
                Text("Game Settings")
                    .font(.title)

                Spacer()
            }
            .padding()

            Toggle(isOn: $isActive) {
                Text("Turn On Per Game Settings")
            }
            .toggleStyle(.checkbox)

            GameSettingsView(gameSettings: $gameSttings)
                .disabled(!isActive)

            Spacer()
        }
        .padding()
    }
}

struct GameSettingsPanel: View {
    @EnvironmentObject private var globalSettings: GlobalSettings

    var body: some View {
        if let profile = globalSettings.currentGameProfile {
            let gameSettings = Binding {
                profile.gameSettings
            } set: { val in
                profile.gameSettings = val
            }
            let isActive = Binding { profile.perGameSettingsOn }
                set: { val in profile.perGameSettingsOn = val }

            GameSettingsPanelView(isActive: isActive, gameSttings: gameSettings)
        } else {
            VStack {
                HStack {
                    Spacer()
                    Text("No Game Selected")
                        .font(.title)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    GameSettingsPanel()
        .environmentObject(GlobalSettings())
}
