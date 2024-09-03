//
//  SidebarSelectedGame.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import SwiftUI

struct SidebarSelectedGame: View {
    @EnvironmentObject private var globalSettings: GlobalSettings

    var selectedGame: GameProfile? {
        globalSettings.currentGameDirectory?.selectedGame
    }

    var body: some View {
        if selectedGame != nil {
            showSelectedGame
        } else {
            noSelection
        }
    }

    @ViewBuilder
    var noSelection: some View {
        SidebarItemChip(imageSource: .asset(name: "NoGameProfileDefaultIcon")) {
            Text("No Game Selected")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }

    @ViewBuilder
    var showSelectedGame: some View {
        if let game = selectedGame {
            SidebarItemChip(
                imageSource: .asset(name: "NoGameProfileDefaultIcon")
            ) {
                VStack {
                    Text("Selected Game")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("\(game.name)")
                        .font(.subheadline)

                    if let modLoader = game.modLoader {
                        Text(
                            "Minecraft: \(game.gameVersion.fullVersion) | \(modLoader.fullVersion)"
                        )
                        .font(.subheadline)
                    } else {
                        Text("Minecraft: \(game.gameVersion.fullVersion)")
                    }
                }
            }
        } else {
            SidebarItemChip(
                imageSource: .systemIcon(name: "exclamationmark.square")
            ) {
                Text("Unknown Error")
            }
        }
    }
}
