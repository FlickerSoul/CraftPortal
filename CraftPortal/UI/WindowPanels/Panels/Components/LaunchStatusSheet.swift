//
//  LaunchStatusSheet.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/14/24.
//

import SwiftUI

private struct LaunchStatusMultiInstanceWarning: View {
    @Environment(\.dismiss) private var dismiss

    let username: String
    @Binding var override: Bool

    var body: some View {
        VStack {
            Text("Warning")
                .font(.title)

            Text(
                "There are already games lauched under the user name '\(username)'. Continue lauching new game intances may cause trouble for existing game plays. We are not responsible for any loss caused by this"
            )
            .font(.headline)

            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }

                Button("Continue", role: .destructive) {
                    override = true
                }
            }
        }
    }
}

#Preview("Multi Instance Warning") {
    @Previewable @State var override = false

    LaunchStatusMultiInstanceWarning(username: "user_name", override: $override)
}

private struct LaunchStatusLoadingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var globalSettings: GlobalSettings
    @EnvironmentObject private var appState: AppState

    @State private var taskDone: [LaunchManager.LaunchSubTask] = []

    let pipe: Pipe = .init()

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(taskDone, id: \.self) { task in
                    HStack(alignment: .center) {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)

                        Divider()

                        Text(task)

                        Spacer()
                    }
                }
            }

            ProgressView().progressViewStyle(.circular)

            Button("Ok") {
                dismiss()
            }
        }
        .task {
            await appState.launchManager.launch(
                globalSettings: globalSettings,
                appState: appState,
                taskNotifier: addTask
            )
        }
    }

    func addTask(_ task: LaunchManager.LaunchSubTask) {
        taskDone.append(task)
    }
}

#Preview("Launch Loading View") {
    LaunchStatusLoadingView()
        .environmentObject(GlobalSettings())
        .environmentObject(AppState())
}

struct LaunchStatusSheet: View {
    @EnvironmentObject private var globalSettings: GlobalSettings
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var multiInstanceOverride: Bool = false

    @State private var noInstance: Bool = false

    var body: some View {
        Group {
            if let player = globalSettings.currentPlayerProfile {
                if noInstance || multiInstanceOverride {
                    LaunchStatusLoadingView()
                } else {
                    LaunchStatusMultiInstanceWarning(
                        username: player.username,
                        override: $multiInstanceOverride
                    )
                }
            } else {
                noPlayerError
            }
        }
        .onAppear {
            noInstance = {
                if let uuid = globalSettings.currentPlayerProfile?.id {
                    return appState.launchManager.noProcessRunning(for: uuid)
                }

                return false

            }()
        }
        .padding()
    }

    @ViewBuilder
    private var noPlayerError: some View {
        ErrorSheetView(
            error: .init(
                title: "Internal State Error",
                description: "Cannot launch game without a player profiel."
            )
        )
    }
}

#Preview("Launch Status Sheet") {
    LaunchStatusSheet()
        .environmentObject(GlobalSettings())
}
