//
//  ContentView.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var displaying: FunctionPanel = .Main

    var body: some View {
        GeometryReader { geometry in
            HStack {
                sidebar
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
            Sidebar(updatePanel: updatePanel)
                .frame(width: 260, height: geometry.size.height)
                .background(
                    FrostGlassEffect(
                        material: .toolTip, blendingMode: .withinWindow
                    ))
        }
    }

    var detailPanel: some View {
        MainPanel()
    }

    func updatePanel(_ panel: FunctionPanel) {
        displaying = panel
    }
}

#Preview {
    let state = AppState()

    ContentView()
        .frame(width: 960, height: 540)
        .environmentObject(state)
}
