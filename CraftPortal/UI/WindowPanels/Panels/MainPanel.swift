//
//  MainPanel.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//

import Path
import SwiftData
import SwiftUI
import SwiftUICore

struct MainPanel: View {
    @EnvironmentObject var appState: AppState
    var updatePanel: (FunctionPanel) -> Void

    var noGameSelected: Bool {
        appState.currentGameProfile == nil
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()

                launchButton
            }
            .padding(32)
        }
    }

    @ViewBuilder
    private var launchButton: some View {
        ZStack {
            if noGameSelected {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 200, height: 80)
                    .foregroundStyle(.gray.opacity(0.8))
            }

            FrostGlassEffect(material: .hudWindow, blendingMode: .withinWindow)
                .clipShape(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .frame(width: 200, height: 80)
        }
        .overlay {
            VStack {
                if noGameSelected {
                    Text("No Game Selected")
                        .font(.headline)
                    Text("Go To Game Library")
                        .font(.subheadline)
                } else {
                    Text("Launch Game")
                        .font(.headline)
                    Text(appState.currentGameProfile!.name)
                        .font(.subheadline)
                }
            }
        }
        .onHover { hovering in
            changeMouseHovering(hovering)
        }
        .onTapGesture {
            if noGameSelected {
                updatePanel(.GameLibrary)
            } else {
                appState.launchManager.launch()
            }
        }
    }
}

#Preview("no game profile") {
    VStack {
        MainPanel { _ in }
            .environmentObject(AppState())
    }
    .background(Image("HomeBackground2"))
}

#Preview("has game profile") {
    VStack {
        MainPanel { _ in }
            .environmentObject(
                AppState(
                    currentGameDirectory: {
                        let dir = GameDirectory(
                            path: Path("~/Library/Application Support/minecraft/")!,
                            directoryType: .Mangled
                        )
                        let game = GameProfile(
                            name: "Test",
                            gameVersion: .Release(
                                major: 1, minor: 21, patch: 0
                            ),
                            modLoader: nil,
                            gameDirectory: dir
                        )
                        dir.addAndSelectGame(game)
                        return dir
                    }()
                )
            )
    }
    .background(Image("HomeBackground2"))
    .modelContainer(
        {
            let schema = Schema(versionedSchema: LatestSchema.self)

            let config = ModelConfiguration(
                schema: schema, isStoredInMemoryOnly: true
            )

            return try! ModelContainer(for: schema, configurations: [config])
        }())
}
