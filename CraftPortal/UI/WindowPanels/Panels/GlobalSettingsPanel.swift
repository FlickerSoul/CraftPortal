//
//  GlobalSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import SwiftUI

struct JVMChooser: View {
    @State private var showingPopover = false

    @EnvironmentObject var appState: AppState

    var body: some View {
        let currentJVM = Binding(
            get: {
                appState.globalSettingsManager.jvmSettings.selectedJVM
            },
            set: {
                appState.globalSettingsManager.change(keyPath: \.jvmSettings.selectedJVM, value: $0)
            }
        )

        HStack {
            Image(systemName: "apple.terminal.on.rectangle")

            VStack {
                if let currentJVM = currentJVM.wrappedValue {
                    Text("JVM \(currentJVM.version)")
                        .font(.headline)
                    Text(currentJVM.path)
                        .font(.footnote)
                } else {
                    Text("No JVM Selected")
                }
            }
        }
        .padding()
        .onTapGesture {
            showingPopover.toggle()
        }
        .hoverCursor()
        .popover(isPresented: $showingPopover) {
            VStack(alignment: .center) {
                Picker("Available JVMs", selection: currentJVM) {
                    ForEach(
                        appState.jvmManager.sequentialVersions
                    ) { jvm in
                        VStack(alignment: .center) {
                            Text(jvm.version)
                                .font(.headline)
                            Text(jvm.path)
                                .font(.subheadline)
                        }
                        .tag(jvm)
                    }

                    Text("None").tag(nil as GameDirectory?)
                }
                .pickerStyle(.radioGroup)
            }
            .padding()
        }
    }
}

struct CurrentGameDirecotryChooser: View {
    @State var showingPopover = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        let currentGameDirectory = Binding(
            get: {
                appState.currentGameDirectory
            },
            set: {
                appState.globalSettingsManager.change(
                    keyPath: \.currentGameDirectory, value: $0
                )
            }
        )

        HStack {
            Image(systemName: "folder")

            VStack {
                if let currentDir = currentGameDirectory.wrappedValue {
                    Text(currentDir.path.string)
                } else {
                    Text("No Game Directory Set")
                }
            }
        }
        .padding()
        .onTapGesture {
            showingPopover.toggle()
        }
        .hoverCursor()
        .popover(isPresented: $showingPopover) {
            VStack {
                Picker(
                    "Available Directories",
                    selection: currentGameDirectory
                ) {
                    ForEach(appState.globalSettingsManager.gameDirectories) {
                        dir in
                        VStack {
                            Text(dir.path.string)
                        }
                    }

                    Text("None").tag(nil as GameDirectory?)
                }
                .pickerStyle(.radioGroup)
            }
            .padding()
        }
    }
}

struct GlobalSettingsPanel: View {
    var body: some View {
        VStack {
            JVMChooser()
            Divider()
            CurrentGameDirecotryChooser()
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
