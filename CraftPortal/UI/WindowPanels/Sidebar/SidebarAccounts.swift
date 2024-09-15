//
//  SidebarAccounts.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//

import SwiftUI

struct SidebarAccounts: View {
    @EnvironmentObject private var globalSettings: GlobalSettings

    var body: some View {
        SidebarItemChip(imageSource: noAccountImage) {
            if let account = globalSettings.currentPlayerProfile {
                accountDisplay(account)
            } else {
                noAccountDisplay
            }
        }
    }

    var noAccountImage: ImageSource {
        .asset(name: "NoAccountDefaultFace")
    }

    var noAccountDisplay: some View {
        VStack(alignment: .leading) {
            Text("No Accounts")
                .font(.headline)
                .foregroundColor(.primary)
            Text("Click here to add an account")
                .font(.subheadline)
        }
    }

    @ViewBuilder
    @inlinable
    func accountDisplay(_ player: PlayerProfile) -> some View {
        VStack(alignment: .leading) {
            Text(player.username)
                .font(.headline)
                .foregroundColor(.primary)
            Text(player.playerType.localizedStringKey)
                .font(.subheadline)
        }
    }
}

#Preview {
    SidebarAccounts()
        .environmentObject(GlobalSettings())
        .frame(width: 400)
}
