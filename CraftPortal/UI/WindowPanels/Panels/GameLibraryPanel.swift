//
//  GameLibraryPanel.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//

import SwiftUI

struct DiscoverProfilesView: View {
    @State var loading: Bool = false
    @State var loadedProfileCount: Int = 0
    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var globalSettings: GlobalSettings
    @Environment(\.dismiss) private var dismiss

    var currentGameDirectory: GameDirectory? {
        globalSettings.currentGameDirectory
    }

    var body: some View {
        VStack {
            if loading {
                ProgressView().progressViewStyle(.circular)
            } else {
                if currentGameDirectory != nil {
                    Text("Loaded \(loadedProfileCount) profiles")
                } else {
                    Text(
                        "The current game directory is not set. Please select a game directory first."
                    )
                }

                Button {
                    dismiss()
                } label: {
                    Text("Ok")
                }
            }
        }
        .padding()
        .task {
            await loadGameDirectoriesAsync()
        }
    }

    func loadGameDirectoriesAsync() async {
        guard let currentGameDirectory else { return }

        loading = true

        let profiles = GameDirectory.discoverProfiles(
            in: currentGameDirectory
        )

        currentGameDirectory.addGames(profiles)
        loadedProfileCount = profiles.count
        loading = false
    }

    func loadGameDirectories() {
        guard let currentGameDirectory else { return }

        loading = true
        DispatchQueue.global().async {
            let profiles = GameDirectory.discoverProfiles(
                in: currentGameDirectory
            )

            DispatchQueue.main.async {
                currentGameDirectory.addGames(profiles)
                self.loadedProfileCount = profiles.count
                self.loading = false
            }
        }
    }
}

struct DiscoverProfilesButton: View {
    @State var showingSheet: Bool = false

    var body: some View {
        Button {
            showingSheet = true
        } label: {
            Image(systemName: "rectangle.and.text.magnifyingglass")
        }
        .help("Discover playable game profiles")
        .sheet(isPresented: $showingSheet) {
            DiscoverProfilesView()
        }
    }
}

struct DirectoryProfileListing: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var globalSettings: GlobalSettings
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            ForEach(
                globalSettings.currentGameDirectory?.gameProfiles ?? []
            ) {
                profile in
                HStack(spacing: 16) {
                    selectedGameIndicator(for: profile)

                    Text(profile.name)
                    Spacer()
                }
                .padding(.vertical, 4)
                .hoverCursor()
                .onTapGesture {
                    globalSettings.currentGameDirectory?.selectGame(profile)
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    @inlinable
    func selectedGameIndicator(for profile: GameProfile?) -> some View {
        HStack {
            VStack {
                if profile
                    == globalSettings.currentGameDirectory?
                    .selectedGame
                {
                    Image(systemName: "checkmark")
                } else {
                    Image(systemName: "circle")
                }
            }
            .frame(width: 16, height: 16)
            Divider()
        }
    }
}

struct GameDirectoryView: View {
    @ViewBuilder
    var title: some View {
        HStack {
            Text("Manage Game Directory")
                .font(.title)
            Spacer()
            Button {
                // TODO: add more
            } label: {
                Image(systemName: "plus")
            }
        }.padding()
    }

    var body: some View {
        VStack {
            title

            HStack {
                CurrentGameDirecotryChooser()
                Spacer()
                DiscoverProfilesButton()
                AddGameDirectory()
            }.padding()

            Divider()

            DirectoryProfileListing()

            Spacer()
        }
        .padding()
    }
}

struct GameLibraryPanel: View {
    var body: some View {
        NavigationStack {
            GameDirectoryView()
        }
        .background(.opacity(0))
    }
}

#Preview {
    GameLibraryPanel()
}
