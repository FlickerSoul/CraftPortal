//
//  CraftPortalApp.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//

import Foundation
import SwiftData

import struct Path.Path
import protocol SwiftUI.App
import struct SwiftUI.Environment
import protocol SwiftUI.Scene
import struct SwiftUI.StateObject
import protocol SwiftUI.View
import struct SwiftUI.WindowGroup

let APP_NAME = "CraftPortalLauncher"

struct RootView: View {
    @StateObject var appState: AppState = .init()
    @Query private var settings: [GlobalSettings]
    @Environment(\.modelContext) private var modelContext

    var globalSettings: GlobalSettings {
        settings.first!
    }

    var body: some View {
        ContentView()
            .frame(width: 960, height: 540)
            .onAppear {
                lauching()
            }
            .environmentObject(appState)
            .environmentObject(globalSettings)
            .sheet(item: $appState.currentError) { error in
                ErrorSheetView(error: error)
            }
        // It's guaranteed that settings has one thing
        // See the init section of main App below
    }

    private func lauching() {
        appState.initializeState(globalSettings: globalSettings)
        //        initializeData() // FIXIME: what's wrong with this??

        appState.finishInitialization()
    }

    private func initializeData() {
        if AppState.isFirstLaunch {
            // If first launch, try populate some things
            if let applicationSupport = FileManager.default.urls(
                for: .applicationSupportDirectory, in: .userDomainMask
            ).first {
                if let minecraftPath =
                    Path(
                        applicationSupport.appendingPathComponent(
                            "minecraft", isDirectory: true
                        ).path(percentEncoded: false)),
                    minecraftPath.exists
                {
                    let dir = GameDirectory(
                        path: minecraftPath.string,
                        directoryType: .Mangled
                    )
                    modelContext.insert(dir)
                }

                if let applicationPath = Path(
                    applicationSupport.appendingPathComponent(
                        APP_NAME, isDirectory: true
                    ).path(percentEncoded: false)),
                    applicationPath.exists
                    || (try? applicationPath.mkdir()) != nil
                {
                    let dir = GameDirectory(
                        path: applicationPath.string,
                        directoryType: .Profile
                    )

                    modelContext.insert(dir)
                }
            }
        } else {
            // try validate things
            if case let .manual(selectedJVM) = globalSettings.selectedJVM,
               !appState.jvmManager.versions.contains(selectedJVM)
            {
                globalSettings.selectedJVM = .automatic
            }
        }

        if modelContext.hasChanges {
            try? modelContext.save()
        }
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
