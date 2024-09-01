//
//  GlobalSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import SwiftUI

struct GlobalSettingsPanel: View {
    @EnvironmentObject var appState: AppState
    @Environment(GlobalSettings.self) private var globalSettings

    @ViewBuilder
    var title: some View {
        HStack {
            Text("Global Settings")
                .font(.title)
            Spacer()
        }.padding()
    }

    var body: some View {
        let gameSettingsBinding = Binding {
            globalSettings.gameSettings
        } set: { val in
            return globalSettings.gameSettings = val
        }
        VStack {
            title

            JVMSettingsView()
            Divider()
            CurrentGameDirectorySettings()
            Divider()
            GameSettingsView(
                gameSettings: gameSettingsBinding
            )
            Spacer()
        }
        .padding()
    }
}

#Preview {
    let appState = {
        let state = AppState()
        state.initializeState()
        return state
    }()
    GlobalSettingsPanel().environmentObject(appState)
}
