import SwiftData

//
//  AccountsPanel.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import SwiftUI

struct AccountsListing: View {
    @Query(sort: \PlayerProfile.username) private var players: [PlayerProfile]

    @Environment(GlobalSettings.self) private var globalSettings

    var body: some View {
        let binding = Binding {
            globalSettings.currentPlayerProfile
        } set: { val in
            globalSettings.currentPlayerProfile = val
        }

        Picker("Select a player", selection: binding) {
            ForEach(players) { player in
                HStack {
                    Text(player.username)

                    Spacer()

                    Button {} label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                }
                .tag(player)
            }

            Text("None").tag(nil as PlayerProfile?)
        }
        .pickerStyle(.radioGroup)
    }
}

struct AddLocalAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username: String = ""
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack {
            HStack {
                Text("Username: ")
                TextField("username", text: $username)
            }

            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Back")
                }

                Button {
                    let user = PlayerProfile(
                        id: UUID(), username: username, playerType: .Local
                    )

                    modelContext.insert(user)
                } label: {
                    Text("Ok")
                }
            }
        }
        .padding()
    }
}

struct AccountsPanel: View {
    @State private var showAddingLocalAccount: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Accounts")
                    .font(.title)

                Spacer()

                HStack {
                    Button {
                        // TODO: add msa account
                    } label: {
                        Image(systemName: "m.square")
                    }
                    .help("Add a microsoft account")

                    Button {
                        showAddingLocalAccount = true
                    } label: {
                        Image(systemName: "icloud.slash")
                    }
                    .help("Add a offline account")
                    .sheet(isPresented: $showAddingLocalAccount) {
                        AddLocalAccountSheet()
                    }
                }
            }
            .padding()

            VStack {
                AccountsListing()
            }.padding()

            Spacer()
        }
        .padding()
    }
}

#Preview {
    AccountsPanel()
}
