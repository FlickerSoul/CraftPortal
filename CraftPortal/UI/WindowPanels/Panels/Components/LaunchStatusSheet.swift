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

private enum LaunchStatus: Equatable {
    case success
    case failed
}

private struct LaunchStatusLoadingView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var globalSettings: GlobalSettings
    @EnvironmentObject private var appState: AppState

    @State private var taskDone: [LaunchSubTaskItem] = []
    @State private var status: LaunchStatus? = nil
    @State private var logs: [String] = []

    @State private var showLogs: Bool = false

    var body: some View {
        VStack {
            HStack {
                progress
                    .transition(.identity)

                Group {
                    if showLogs {
                        log
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .push(from: .top),
                        removal: .push(from: .bottom)
                    ))
            }

            HStack(alignment: .center) {
                Button("Ok") {
                    dismiss()
                }

                Button(showLogs ? "Hide Logs" : "Show Logs") {
                    withAnimation {
                        showLogs.toggle()
                    }
                }
            }
        }
        .task {
            await launch()
        }
    }

    @ViewBuilder
    private var log: some View {
        ScrollViewReader { proxy in
            ScrollView([.horizontal, .vertical]) {
                LazyVStack(alignment: .leading) {
                    ForEach(Array(logs.enumerated()), id: \.0) { _, log in
                        Text(log)
                        Divider()
                    }
                }
            }
            .onChange(of: logs.count) { _, newValue in
                proxy.scrollTo(newValue - 1)
            }
        }
        .defaultScrollAnchor(.bottom)
    }

    @ViewBuilder
    private var progress: some View {
        if taskDone.isEmpty {
            ProgressView()
                .progressViewStyle(.linear)
        } else {
            ScrollView {
                ForEach(Array(taskDone.enumerated()), id: \.0) {
                    index, task in
                    VStack {
                        HStack(alignment: .center) {
                            Image(
                                systemName: status == .failed
                                    && index == taskDone.count - 1
                                    ? "xmark.circle" : task.icon
                            )
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)

                            Divider()

                            Text(task.name)

                            Spacer()
                        }

                        if status == nil && index == taskDone.count - 1 {
                            ProgressView()
                                .progressViewStyle(.linear)
                        }
                    }
                }
            }
        }
    }

    private func addTask(_ task: LaunchSubTask) {
        switch task {
        case .success:
            status = .success
        case .failed:
            status = .failed
        case let .step(item):
            taskDone.append(item)
        }
    }

    private func launch() async {
        let pipe = Pipe()

        pipe.fileHandleForReading.readabilityHandler = { handle in
            guard
                let output = String(
                    data: handle.availableData, encoding: .utf8
                ),
                !output.isEmpty
            else { return }

            DispatchQueue.main.async {
                logs.append(
                    output.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
        }

        await appState.launchManager.launch(
            globalSettings: globalSettings,
            appState: appState,
            taskNotifier: addTask,
            pipe: pipe
        )
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
