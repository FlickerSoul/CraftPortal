//
//  GlobalSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import SwiftUI

struct GlobalSettingsPanel: View {
    @EnvironmentObject var appState: AppState

    @ViewBuilder
    var title: some View {
        HStack {
            Text("Global Settings")
                .font(.title)
            Spacer()
        }.padding()
    }

    var body: some View {
        VStack {
            title

            JVMSettingsView()
            Divider()
            CurrentGameDirectorySettings()
            Divider()
            GameSettingsView(
                gameSettings: appState.globalSettingsManager.globalGameSettings
            ) {
                appState.globalSettingsManager.saveSettings()
            }
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
