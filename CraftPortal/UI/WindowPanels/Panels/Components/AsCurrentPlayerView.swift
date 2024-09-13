//
//  AsCurrentPlayerView.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/13/24.
//

import SwiftUI

struct AsCurrentPlayerView: View {
    let player: PlayerProfile
    let successCallback: () -> Void

    @EnvironmentObject private var globalSettings: GlobalSettings

    var body: some View {
        VStack {
            Text("Use \(player.username) as the current account?")

            HStack {
                Button("No") {
                    next()
                }

                Button("Ok") {
                    next()
                }
            }
        }
        .padding()
    }

    private func next() {
        globalSettings.currentPlayerProfile = player
        successCallback()
    }
}
