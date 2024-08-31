//
//  GlobalSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import SwiftUI

struct GlobalSettingsPanel: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            JVMSettingsView()
            Divider()
            CurrentGameDirectorySettings()
            Divider()
            GameSettingsView(
                gameSettings: appState.globalSettingsManager.globalGameSettings)
            {
                appState.globalSettingsManager.saveSettings()
            }
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
