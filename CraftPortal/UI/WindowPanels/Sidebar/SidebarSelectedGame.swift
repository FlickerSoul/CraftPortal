//
//  SidebarSelectedGame.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import SwiftUI

struct SidebarSelectedGame: View {
    @EnvironmentObject private var globalSettings: GlobalSettings

    var body: some View {
        if globalSettings.currentGameProfile != nil {
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
        if let game = globalSettings.currentGameProfile {
            SidebarItemChip(
                imageSource: .asset(name: "NoGameProfileDefaultIcon")
            ) {
                VStack(alignment: .leading) {
                    Text("\(game.name)")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("Minecraft: \(game.gameVersion.fullVersion)")
                        .font(.subheadline)

                    if let modLoader = game.modLoader {
                        Text("Mod Loader: \(modLoader.fullVersion)")
                            .font(.subheadline)
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
