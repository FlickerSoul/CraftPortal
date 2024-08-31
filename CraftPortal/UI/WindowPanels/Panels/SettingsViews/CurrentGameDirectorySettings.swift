//
//  CurrentGameDirectorySettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import SwiftUI

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
                        .font(.headline)
                    Text(currentDir.path.string)
                        .font(.footnote)
                } else {
                    Text("No Game Directory Set")
                }
            }
        }
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
            addGameDirectory(chooseFolder(message: "Select a Game Directory"))
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
        .padding()
    }
}
