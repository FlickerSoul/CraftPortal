import SwiftData

//
//  CurrentGameDirectorySettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import SwiftUI

struct CurrentGameDirecotryChooser: View {
    @State private var showingPopover = false
    @EnvironmentObject private var globalSettings: GlobalSettings
    @Query private var gameDirectories: [GameDirectory]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            Image(systemName: "folder")

            VStack(alignment: .leading) {
                Text("Current Game Directory")
                    .font(.headline)
                if let currentDir = globalSettings.currentGameDirectory {
                    Text(currentDir.path)
                        .font(.footnote)
                } else {
                    Text("No Game Directory Selected")
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
                    selection: $globalSettings.currentGameDirectory
                ) {
                    ForEach(gameDirectories) {
                        dir in
                        HStack {
                            Text(dir.path)
                            Spacer()
                            Button(role: .destructive) {
                                deleteDirectory(dir)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
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

    func deleteDirectory(_ dir: GameDirectory) {
        if globalSettings.currentGameDirectory == dir {
            globalSettings.currentGameDirectory = nil
        }

        modelContext.delete(dir)
    }
}

struct AddGameDirectoryOption: View {
    @State private var selectedStyle: GameDirectoryStructureType = .isolated
    @State private var setAsCurrent: Bool = true
    @State private var discoverProfile: Bool = true
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var globalSettings: GlobalSettings
    @Environment(\.modelContext) private var modelContext

    let pathURL: URL

    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Picker("Folder Structure Style", selection: $selectedStyle) {
                    ForEach(GameDirectoryStructureType.allCases) { kase in
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
                    let newDir = GameDirectory(
                        path: pathURL.path(percentEncoded: false),
                        directoryType: selectedStyle
                    )

                    modelContext.insert(newDir)

                    if setAsCurrent {
                        globalSettings.currentGameDirectory = newDir
                    }

                    // TODO: discover profiles
                    if discoverProfile {}

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
        .help("Select a game directory to add to the list of game directories.")
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
