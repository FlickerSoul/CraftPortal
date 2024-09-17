//
//  LaunchStatusInfoView.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/15/24.
//
import Combine
import SwiftData
import SwiftUI

struct LaunchStatusInfoView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var globalSettings: GlobalSettings
    @EnvironmentObject private var appState: AppState

    @State private var viewModel: LaunchStatusViewModel

    private let inWindow: Bool
    private let profileId: UUID?

    init(
        inWindow: Bool, profileId: UUID? = nil,
        viewModel: LaunchStatusViewModel = .init()
    ) {
        self.inWindow = inWindow
        self.profileId = profileId
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            HStack {
                progress
                    .transition(.identity)
                    .frame(width: 200)

                Group {
                    if viewModel.showLogs || inWindow {
                        Divider()
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

                Button(viewModel.showLogs ? "Hide Logs" : "Show Logs") {
                    withAnimation {
                        viewModel.toggleShowLogs()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var progress: some View {
        if viewModel.taskDone.isEmpty {
            VStack(alignment: .center) {
                Text("Preparing...")
                    .font(.headline)

                ProgressView()
                    .progressViewStyle(.linear)
            }
        } else {
            ScrollView {
                ForEach(Array(viewModel.taskDone.enumerated()), id: \.0) {
                    index, task in
                    VStack {
                        HStack {
                            Image(
                                systemName: viewModel.isLaunchFailed
                                    && index == viewModel.lastTaskIndex
                                    ? "xmark.circle" : task.icon
                            )
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)

                            Divider()

                            Text(task.name)

                            Spacer()
                        }

                        if viewModel.isLaunchRunning
                            && index == viewModel.lastTaskIndex
                        {
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
            HStack {
                Text("Logs")
                    .font(.title)

                Spacer()

                Toggle(isOn: $viewModel.scrollToBottom) {
                    Text("Scroll to bottom")
                }
            }

            ScrollViewReader { proxy in
                ScrollView([.horizontal, .vertical]) {
                    ForEach(viewModel.enumeratedLogs, id: \.0) {
                        _, log in
                        VStack(alignment: .leading) {
                            Text(log)
                            Divider()
                        }
                    }
                }
                .onReceive(viewModel.logUpdatePublisher) { _ in
                    if viewModel.scrollToBottom {
                        withAnimation {
                            proxy.scrollTo(viewModel.lastLogIndex, anchor: .leading)
                        }
                    }
                }
            }
            .defaultScrollAnchor(.bottom)
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
                viewModel.sendLog(output)
            }
        }

        var profile: GameProfile? = nil

        if let profileId {
            let context = ModelContext(modelContext.container)
            let fetched = try? context.fetch(
                FetchDescriptor<GameProfile>(
                    predicate: #Predicate { item in
                        item.id == profileId
                    }))

            if let fetched, let fetchedProfile = fetched.first {
                profile = fetchedProfile
            }
        }

        await appState.launchManager.launch(
            globalSettings: globalSettings,
            appState: appState,
            taskNotifier: addTask,
            profile: profile,
            pipe: pipe
        )
    }

    func addTask(_ task: LaunchSubTask) {
        viewModel.addTask(task)
    }
}

// MARK: - View Model

extension LaunchStatusInfoView {
    enum LaunchStatus: Equatable {
        case success
        case failed
    }

    @Observable
    class LaunchStatusViewModel {
        private(set) var taskDone: [LaunchSubTaskItem] = []
        private(set) var status: LaunchStatus?
        private(set) var logs: [String] = []
        private(set) var showLogs: Bool = false
        var scrollToBottom: Bool = true
        private let bufferSize = 128
        private let collectTime: RunLoop.SchedulerTimeType.Stride =
            .milliseconds(500)

        let logPublisher = PassthroughSubject<String, Never>()
        let logUpdatePublisher: AnyPublisher<[String], Never>
        private var cancellable: AnyCancellable?

        init() {
            logUpdatePublisher =
                logPublisher
                    .buffer(
                        size: bufferSize, prefetch: .byRequest,
                        whenFull: .dropOldest
                    ) // TODO: consider raising errors?
                    .map { value in
                        value.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    .collect(.byTime(RunLoop.main, collectTime))
                    .eraseToAnyPublisher()

            cancellable =
                logUpdatePublisher
                    .sink(receiveValue: { [weak self] values in
                        self?.logs.append(contentsOf: values)
                    })
        }

        var lastTaskIndex: Int {
            taskDone.count - 1
        }

        var lastLogIndex: Int {
            logs.count - 1
        }

        var isLaunchFailed: Bool {
            status == .failed
        }

        var isLaunchRunning: Bool {
            status == nil
        }

        var enumeratedLogs: [(Int, String)] {
            Array(logs.enumerated())
        }

        func toggleShowLogs() {
            showLogs.toggle()
        }

        func addTask(_ task: LaunchSubTask) {
            switch task {
            case .success:
                status = .success
            case .failed:
                status = .failed
            case let .step(item):
                taskDone.append(item)
            }
        }

        func sendLog(_ log: String) {
            logPublisher.send(log)
        }
    }
}

#Preview("Launch Loading View") {
    @Previewable @State var inWindow = false
    LaunchStatusInfoView(inWindow: inWindow)
        .environmentObject(GlobalSettings())
        .environmentObject(AppState())
}
