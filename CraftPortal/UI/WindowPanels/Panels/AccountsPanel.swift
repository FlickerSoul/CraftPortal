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

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var globalSettings: GlobalSettings

    var body: some View {
        ScrollView {
            ForEach(players) { player in
                HStack {
                    SelectorIndicator(
                        selected: player == globalSettings.currentPlayerProfile
                    )
                    .onTapGesture {
                        globalSettings.currentPlayerProfile = player
                    }

                    Text(player.username)
                        .font(.headline)

                    Spacer()
                    HStack {
                        Button {
                            copyUUID(player.id)
                        } label: {
                            Image(systemName: "person.text.rectangle")
                        }

                        Button(role: .destructive) {
                            if player == globalSettings.currentPlayerProfile {
                                globalSettings.currentPlayerProfile = nil
                            }

                            modelContext.delete(player)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }

    private func copyUUID(_ uuid: UUID) {
        copyText(uuid.uuidString)
    }
}

struct AddLocalAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username: String = ""
    @State private var uuid: UUID? = nil
    @State private var advancedExpanded: Bool = false

    private let defaultNewUUID = UUID()

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        let uuidBinding = Binding {
            uuid?.uuidString ?? ""
        } set: { val in
            uuid = UUID(uuidString: val) ?? UUID(flatUUIDString: val)
        }

        VStack {
            HStack {
                Text("Username")
                TextField("Username", text: $username)
            }

            DisclosureGroup("Advanced", isExpanded: $advancedExpanded) {
                HStack {
                    Text("UUID")
                    TextField(
                        "UUID", text: uuidBinding,
                        prompt: Text(defaultNewUUID.uuidString)
                    )
                }
            }

            HStack {
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Back")
                }

                Button {
                    let user = PlayerProfile(
                        id: uuid ?? defaultNewUUID, username: username,
                        playerType: .Local
                    )

                    modelContext.insert(user)

                    try? modelContext.save()

                    dismiss()
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
    @State private var showAddingMSAccount: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Accounts")
                    .font(.title)

                Spacer()

                HStack {
                    Button {
                        showAddingMSAccount = true
                    } label: {
                        Image(systemName: "m.square")
                    }
                    .help("Add a microsoft account")
                    .sheet(isPresented: $showAddingMSAccount) {
                        MSAccountAdderView()
                    }

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
