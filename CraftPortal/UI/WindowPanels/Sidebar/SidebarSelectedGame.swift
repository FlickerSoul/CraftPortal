//
//  SidebarSelectedGame.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import SwiftUI

struct SidebarSelectedGame: View {
    @EnvironmentObject private var globalSettings: GlobalSettings

    var versionString: String {
        if let game = globalSettings.currentGameProfile {
            if let modLoader = game.modLoader {
                return
                    "\(game.gameVersion.fullVersion) - \(modLoader.fullVersion)"
            } else {
                return game.gameVersion.fullVersion
            }
        }
        return ""
    }

    var body: some View {
        SidebarItemChip(
            imageSource: .asset(name: "NoGameProfileDefaultIcon")
        ) {
            VStack(alignment: .leading) {
                if let game = globalSettings.currentGameProfile {
                    showSelectedGame(game)
                } else {
                    noSelectedGame
                }
            }
            .transition(.opacity)
        }
    }

    @ViewBuilder
    @inlinable
    func showSelectedGame(_ game: GameProfile) -> some View {
        Text("\(game.name)")
            .font(.headline)
            .foregroundStyle(.primary)
            .lineLimit(1)
            .truncationMode(.tail)

        Text("\(versionString)")
            .font(.subheadline)
            .lineLimit(1)
            .truncationMode(.middle)
    }

    @ViewBuilder
    var noSelectedGame: some View {
        Text("No Game Selected")
            .font(.headline)
            .foregroundColor(.primary)
    }
}
