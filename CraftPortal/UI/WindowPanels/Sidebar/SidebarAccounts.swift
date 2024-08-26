//
//  SidebarAccounts.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//

import SwiftUI

struct SidebarAccounts: View {
    @EnvironmentObject var appState: AppState

    var emptyAccount: Bool {
        appState.currentUserProfile == nil
    }

    var body: some View {
        if emptyAccount {
            noAccountDisplay
        } else {
            accountDisplay
        }
    }

    var noAccountDisplay: some View {
        SidebarItemChip(imageSource: .asset(name: "NoAccountDefaultFace")) {
            VStack(alignment: .leading) {
                Text("No Accounts")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Click here to add an account")
                    .font(.subheadline)
            }
        }
    }

    var accountDisplay: some View {
        Text("Has Account!")
    }
}

#Preview {
    SidebarAccounts()
        .environmentObject(AppState())
        .frame(width: 400)
}
