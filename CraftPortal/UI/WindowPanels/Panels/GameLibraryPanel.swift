//
//  GameLibraryPanel.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//

import SwiftData
import SwiftUI

struct DiscoverProfilesView: View {
    @State var loading: Bool = false
    @State var loadedProfileCount: Int = 0
    @EnvironmentObject private var globalSettings: GlobalSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

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
        .onAppear {
            loadGameDirectoriesAsync()
        }
    }

    func loadGameDirectoriesAsync() {
        guard let currentGameDirectory else { return }

        loading = true

        let profiles = GameDirectory.discoverProfiles(
            in: currentGameDirectory
        )

        for profile in profiles {
            modelContext.insert(profile)
            profile.gameDirectory = currentGameDirectory
        }

        loadedProfileCount = profiles.count
        loading = false
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

struct DirectoryProfilePicture: View {
    @State private var isHovered: Bool = false
    @State private var showProfilePickerPopover: Bool = false
    @Binding var profilePictureName: String

    var body: some View {
        Image(profilePictureName)
            .resizable()
            .scaledToFit()
            .frame(width: 32, height: 32)
            .onHover { hovering in
                isHovered = hovering
            }
            .hoverCursor()
            .border(isHovered ? .gray : .clear)
            .onTapGesture {
                showProfilePickerPopover = true
            }
            .popover(isPresented: $showProfilePickerPopover) {
                ProfilePicturePicker(currentProfileName: $profilePictureName)
            }
    }
}

struct DeleteProfileConfirmation: View {
    let profile: GameProfile
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State var showingDeleteFailed: Bool = false

    var body: some View {
        VStack {
            Text("Are you sure to delete this profile")
            Text(profile.name)
            Text("under the directory")
            Text(profile.gameDirectory.path)

            HStack {
                Button("Back", role: .cancel) {
                    dismiss()
                }

                Button("Delete", role: .destructive) {
                    do {
                        try profile.gameDirectory.deleteGame(profile)
                    } catch {
                        appState.setError(title: "Failed to delete profile", description: error.localizedDescription)
                    }

                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

struct DirectoryProfileListingEntry: View {
    @Bindable var profile: GameProfile
    @State var showingPopover: Bool = false
    @State var showingDeleteConfirmation: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            DirectoryProfilePicture(
                profilePictureName: $profile.profilePicture
            )

            Text(profile.name)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer(minLength: 32)

            HStack {
                Button {
                    showingPopover = true
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .buttonStyle(.borderless)
                .popover(isPresented: $showingPopover) {
                    VStack(alignment: .leading) {
                        Button {
                            let path = profile.getSavesPath()
                            NSWorkspace.shared.open(path.url)
                        } label: {
                            Image(systemName: "flag.checkered")
                            Text("Open Saves Folder")
                        }
                        .buttonStyle(.borderless)

                        Button {
                            let path = profile.getProfilePath()
                            NSWorkspace.shared.open(path.url)
                        } label: {
                            Image(systemName: "folder.badge.gearshape")
                            Text("Open Game Folder")
                        }
                        .buttonStyle(.borderless)

                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                            Text("Delete Game Profile")
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding()
                }
                .sheet(isPresented: $showingDeleteConfirmation) {
                    DeleteProfileConfirmation(profile: profile)
                }
            }
        }
    }
}

struct DirectoryProfileListing: View {
    @EnvironmentObject private var globalSettings: GlobalSettings
    @Query(filter: Predicate<GameProfile>.false) private var gameProfiles:
        [GameProfile]

    init(directory: GameDirectory?) {
        let descriptor: FetchDescriptor<GameProfile>
        let sortDescriptors = [
            SortDescriptor(\GameProfile.lastPlayed, order: .reverse),
            SortDescriptor(\GameProfile.name),
        ]

        if let directory {
            let id = Optional.some(directory.id)

            descriptor = FetchDescriptor<GameProfile>(
                predicate: #Predicate {
                    id == $0._gameDirectory?.id
                },
                sortBy: sortDescriptors
            )
        } else {
            descriptor = FetchDescriptor<GameProfile>(
                predicate: Predicate<GameProfile>.false,
                sortBy: sortDescriptors
            )
        }

        _gameProfiles = Query(descriptor)
    }

    var body: some View {
        ScrollView {
            ForEach(gameProfiles) {
                profile in
                HStack(spacing: 16) {
                    SelectorIndicator(
                        selected:
                        profile == globalSettings.currentGameProfile
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            globalSettings.currentGameProfile = profile
                        }
                    }

                    DirectoryProfileListingEntry(profile: profile)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
    }
}

struct GameDirectoryView: View {
    @EnvironmentObject private var globalSettings: GlobalSettings

    @ViewBuilder
    var title: some View {
        HStack {
            Text("Manage Games")
                .font(.title)
            Spacer()
            Button {
                // TODO: add more
            } label: {
                Image(systemName: "plus")
            }
            .help("Add new games or mods")
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

            DirectoryProfileListing(
                directory: globalSettings.currentGameDirectory
            )

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
        .environmentObject(GlobalSettings())
        .modelContainer(
            try! ModelContainer(
                for: Schema(versionedSchema: LatestSchema.self),
                configurations: .init(isStoredInMemoryOnly: true)
            )
        )
}
