//
//  CraftPortalApp.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//

import SwiftData
import SwiftUI

@main
struct CraftPortalApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema(versionedSchema: LatestSchema.self)

        let modelConfiguration = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema, configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject var appState: AppState = .init()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 960, height: 540)
                .environmentObject(appState)
                .onAppear {
                    lauching()
                }
        }
        .windowResizability(.contentSize)
        .modelContainer(sharedModelContainer)
    }

    private func lauching() {
        appState.initializeState()
    }
}
