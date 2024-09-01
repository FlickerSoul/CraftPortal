//
//  CraftPortalApp.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//

import SwiftData
import SwiftUI

let APP_NAME = "CraftPortalLauncher"

struct RootView: View {
    @StateObject var appState: AppState = .init()
    @Query private var settings: [GlobalSettings]

    var body: some View {
        ContentView()
            .frame(width: 960, height: 540)
            .environmentObject(appState)
            .onAppear {
                lauching()
            }
            .environment(settings.first!)
        // It's guaranteed that settings has one thing
        // See the init section of main App below
    }

    private func lauching() {
        appState.initializeState()
    }
}

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

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .windowResizability(.contentSize)
        .modelContainer(sharedModelContainer)
    }

    init() {
        let context = sharedModelContainer.mainContext
        if let settinsCollection = try? context.fetch(
            FetchDescriptor<GlobalSettings>())
        {
            if settinsCollection.isEmpty {
                let globalSettings = GlobalSettings()
                context.insert(globalSettings)
            }
        } else {
            print("cannot fetch settings")
        }
    }
}
