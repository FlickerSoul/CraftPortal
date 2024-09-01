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
    @Environment(\.dismiss) var dismiss

    var currentGameDirectory: GameDirectory? {
        appState.currentGameDirectory
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
        .onAppear(perform: loadGameDirectories)
    }

    func loadGameDirectories() {
        if let currentGameDirectory {
            loading = true
            DispatchQueue.global().async {
                let profiles = GameDirectory.discoverProfiles(
                    in: currentGameDirectory)
                self.appState.globalSettingsManager.addProfiles(
                    profiles: profiles)

                DispatchQueue.main.async {
                    self.loadedProfileCount = profiles.count
                    self.loading = false
                }
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

    var body: some View {
        VStack {
            Text("Profile List (\(appState.currentGameDirectory?.gameProfiles.count ?? 0))")
            ScrollView {
                LazyVStack {
                    ForEach(appState.currentGameDirectory?.gameProfiles ?? []) {
                        profile in
                        HStack(spacing: 16) {
                            HStack {
                                if profile == appState.currentGameProfile {
                                    Image(systemName: "checkmark")
                                } else {
                                    Image(systemName: "circle")
                                }
                                Divider()
                            }

                            Text(profile.name)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .hoverCursor()
                        .onTapGesture {
                            // TODO: fix this
//                            if appState.currentGameDirectory != nil {
//                                appState.globalSettingsManager.change(keyPath: \.currentGameDirectory!.selectedGame, value: profile)
//                            }
                        }
                    }
                }
            }
        }
        .padding()
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
