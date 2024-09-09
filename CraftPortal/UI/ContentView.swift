//
//  ContentView.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//

import SwiftData
import SwiftUI

private struct LoadingView: View {
    var body: some View {
        VStack {
            Text("Loading...")
                .font(.title)
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}

struct ContentView: View {
    @State private var displaying: FunctionPanel = .Home
    @State private var actualDisplaying: FunctionPanel = .Home
    @State private var panelTransition: AnyTransition = .push(from: .bottom)

    var isInitialized: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    withAnimation(.none) {
                        sidebar
                            .frame(width: 260, height: geometry.size.height)
                            .background(
                                FrostGlassEffect(
                                    material: .sidebar,
                                    blendingMode: .withinWindow
                                ))
                    }

                    VStack {
                        detailPanel
                            .frame(
                                width: geometry.size.width - 260,
                                height: geometry.size.height
                            )
                            .transition(panelTransition)
                    }
                    .background(
                        FrostGlassEffect(
                            material: actualDisplaying == .Home
                                ? nil : .hudWindow,
                            blendingMode: .withinWindow
                        )
                    )
                }
                .frame(
                    width: geometry.size.width, height: geometry.size.height
                )

                if !isInitialized {
                    LoadingView()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .background(
                            FrostGlassEffect(
                                material: .hudWindow,
                                blendingMode: .withinWindow
                            )
                        )
                }
            }
            .animation(.easeIn(duration: 0.3), value: isInitialized)
        }
        .background(
            Image("HomeBackground2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .onChange(of: displaying) { oldValue, newValue in
            if newValue.rawValue > oldValue.rawValue {
                panelTransition = .push(from: .bottom)
            } else {
                panelTransition = .push(from: .top)
            }

            withAnimation(.easeInOut(duration: 0.5)) {
                actualDisplaying = displaying
            }
        }
    }

    @ViewBuilder
    var sidebar: some View {
        Sidebar(updatePanel: updatePanel)
    }

    @ViewBuilder
    var detailPanel: some View {
        switch actualDisplaying {
        case .Home:
            MainPanel(updatePanel: updatePanel)
        case .Accounts:
            AccountsPanel()
        case .GlobalSettings:
            GlobalSettingsPanel()
        case .GameSettings:
            GameSettingsPanel()
        case .GameLibrary:
            GameLibraryPanel()
        }
    }

    func updatePanel(_ panel: FunctionPanel) {
        displaying = panel
    }
}

#Preview {
    @Previewable @State var isInitialized: Bool = false

    ContentView(isInitialized: isInitialized)
        .frame(width: 960, height: 540)
        .environmentObject(GlobalSettings())
        .modelContainer(
            try! ModelContainer(
                for: Schema(versionedSchema: LatestSchema.self),
                configurations: .init(isStoredInMemoryOnly: true)
            ))
}
