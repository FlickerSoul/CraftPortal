//
//  GlobalSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import SwiftUI

struct GlobalSettingsPanel: View {
    @EnvironmentObject private var globalSettings: GlobalSettings

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
                gameSettings: $globalSettings.gameSettings
            )
            Spacer()
        }
        .padding()
    }
}

#Preview {
    GlobalSettingsPanel()
        .environmentObject(GlobalSettings())
}
