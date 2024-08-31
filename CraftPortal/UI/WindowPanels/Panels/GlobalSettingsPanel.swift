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
                appState.globalSettingsManager.change(
                    keyPath: \.jvmSettings.selectedJVM, value: $0
                )
            }
        )

        HStack {
            Image(systemName: "apple.terminal.on.rectangle")

            VStack(alignment: .leading) {
                if let currentJVM = currentJVM.wrappedValue {
                    Text("Java \(currentJVM.version)")
                        .font(.headline)
                    Text(currentJVM.path.string)
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
                            Text(jvm.path.string)
                                .font(.subheadline)
                        }
                        .tag(jvm)
                    }

                    Text("None").tag(nil as JVMInformation?)
                }
                .pickerStyle(.radioGroup)
            }
            .padding()
        }
    }
}

struct AddJVMPath: View {
    var body: some View {
        Button {
            // TODO: add jvm path
        } label: {
            Image(systemName: "plus.app")
        }
    }
}

struct DiscoverJVMButton: View {
    var body: some View {
        Button {
            // TODO: run discover JVM
        } label: {
            Image(systemName: "magnifyingglass")
        }
    }
}

struct JVMSettingsView: View {
    var body: some View {
        HStack {
            JVMChooser()
            Spacer()
            DiscoverJVMButton()
            AddJVMPath()
        }
    }
}

struct CurrentGameDirecotryChooser: View {
    @State private var showingPopover = false
    @EnvironmentObject private var appState: AppState

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

            VStack(alignment: .leading) {
                if let currentDir = currentGameDirectory.wrappedValue {
                    Text("Current Game Directory")
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
                    ForEach(
                        Array(
                            zip(
                                appState.globalSettingsManager.gameDirectories
                                    .indices,
                                appState.globalSettingsManager.gameDirectories
                            )),
                        id: \.0
                    ) {
                        index, dir in
                        HStack {
                            Text(dir.path.string)
                            Spacer()
                            Button(action: {
                                deleteDirectory(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .tag(dir)
                    }

                    Text("None").tag(nil as GameDirectory?)
                }
                .pickerStyle(.radioGroup)
            }
            .padding()
        }
    }

    func deleteDirectory(at index: Int) {
        if let selected = appState.currentGameDirectory,
           let foundIndex = appState.globalSettingsManager.gameDirectories
           .firstIndex(of: selected)
        {
            if index == foundIndex {
                appState.globalSettingsManager.change(
                    keyPath: \.currentGameDirectory, value: nil
                )
            }
        }

        appState.globalSettingsManager.removeDirectory(at: index)
    }
}

struct AddGameDirectoryOption: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedStyle: GameDirectoryType = .Profile
    @State private var setAsCurrent: Bool = true
    @State private var discoverProfile: Bool = true
    @Environment(\.dismiss) private var dismiss

    let pathURL: URL

    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Picker("Folder Style", selection: $selectedStyle) {
                    ForEach(GameDirectoryType.allCases) { kase in
                        Text(kase.id)
                            .tag(kase)
                    }
                }.pickerStyle(.radioGroup)

                Toggle(isOn: $setAsCurrent) {
                    Text("Use as Current Game Directory")
                }
                .toggleStyle(.checkbox)

                Toggle(isOn: $discoverProfile) {
                    Text("Discover Game Profiles")
                }
                .toggleStyle(.checkbox)
            }

            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }

                Button {
                    appState.globalSettingsManager.addDirectory(
                        withURL: pathURL, type: selectedStyle,
                        setAsCurrent: setAsCurrent,
                        discoverProfile: discoverProfile
                    )

                    dismiss()
                } label: {
                    Text("Add Directory")
                }
            }
        }
        .padding()
    }
}

struct AddGameDirectory: View {
    @State private var showingSheet: Bool = false
    @State private var selectedURL: URL? = nil

    var body: some View {
        Button {
            addGameDirectory(chooseFolder())
        } label: {
            Image(systemName: "folder.badge.plus")
        }
        .sheet(
            isPresented: $showingSheet,
            onDismiss: {
                selectedURL = nil
            }
        ) {
            AddGameDirectoryOption(pathURL: selectedURL!)
        }
        .onChange(of: selectedURL) { _, newValue in
            if newValue != nil {
                showingSheet = true
            }
        }
    }

    func addGameDirectory(_ url: URL?) {
        guard let url = url else { return }
        selectedURL = url
    }
}

struct CurrentGameDirectorySettings: View {
    var body: some View {
        HStack {
            CurrentGameDirecotryChooser()
            Spacer()
            AddGameDirectory()
        }
    }
}

struct GlobalSettingsPanel: View {
    var body: some View {
        VStack {
            JVMSettingsView()
            Divider()
            CurrentGameDirectorySettings()
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
