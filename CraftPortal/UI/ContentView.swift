//
//  ContentView.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//

import SwiftData
import SwiftUI

enum WindowPanel {
    case Main
    case Account
    case Settings
    case GameSelection
}

struct ContentView: View {
    @State private var displaying: WindowPanel = .Main

    var body: some View {
        GeometryReader { geometry in
            HStack {
                sidebar

                midDivider

                detailPanel
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                Image("MainBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
        }
    }

    var sidebar: some View {
        GeometryReader { geometry in
            SideBar()
                .frame(width: 260, height: geometry.size.height)
                .background(
                    FrostGlassEffect(
                        material: .toolTip, blendingMode: .withinWindow
                    ))
        }
    }

    var midDivider: some View {
        Divider()
    }

    var detailPanel: some View {
        MainPanel()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .frame(width: 960, height: 540)
}
