//
//  LaunchStatusLoadingView.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/15/24.
//
import SwiftUI

private enum LaunchStatus: Equatable {
    case success
    case failed
}

struct LaunchStatusInfoView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var globalSettings: GlobalSettings
    @EnvironmentObject private var appState: AppState

    @State private var taskDone: [LaunchSubTaskItem] = []
    @State private var status: LaunchStatus? = nil
    @State private var logs: [String] = []

    @State private var showLogs: Bool = false

    let inWindow: Bool

    var body: some View {
        VStack {
            HStack {
                progress
                    .transition(.identity)
                    .frame(width: 200)

                Group {
                    if showLogs || inWindow {
                        log
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .push(from: .top),
                        removal: .push(from: .bottom)
                    ))
            }

            controls
        }
        .padding()
        .task {
            await launch()
        }
    }

    @ViewBuilder
    private var controls: some View {
        if !inWindow {
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
    }

    @ViewBuilder
    private var progress: some View {
        if taskDone.isEmpty {
            VStack(alignment: .center) {
                ProgressView()
                    .progressViewStyle(.linear)
            }
        } else {
            ScrollView {
                ForEach(Array(taskDone.enumerated()), id: \.0) {
                    index, task in
                    VStack {
                        HStack {
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

    @ViewBuilder
    private var log: some View {
        VStack(alignment: .leading) {
            Text("Logs")
                .font(.title)

            GeometryReader { _ in
                ScrollViewReader { proxy in
                    ScrollView([.horizontal, .vertical]) {
                        ForEach(Array(logs.enumerated()), id: \.0) {
                            _, log in
                            VStack(alignment: .leading) {
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
    @Previewable @State var inWindow = false
    LaunchStatusInfoView(inWindow: inWindow)
        .environmentObject(GlobalSettings())
        .environmentObject(AppState())
}
