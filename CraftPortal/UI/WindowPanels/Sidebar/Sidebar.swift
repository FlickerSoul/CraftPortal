//
//  Sidebar.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//

import SwiftUI

struct Sidebar: View {
    let updatePanel: (FunctionPanel) -> Void

    var body: some View {
        VStack {
            SidebarAccounts()
                .onTapGesture {
                    updatePanel(.Accounts)
                }

            Spacer()

            SidebarHome()
                .onTapGesture {
                    updatePanel(.Home)
                }
            SidebarSelectedGame()
                .onTapGesture {
                    updatePanel(.GameSettings)
                }
            SidebarGameLibrary()
                .onTapGesture {
                    updatePanel(.GameLibrary)
                }

            Spacer()

            SidebarSettings()
                .onTapGesture {
                    updatePanel(.GlobalSettings)
                }
        }
    }
}

#Preview {
    Sidebar(updatePanel: { _ in })
        .frame(width: 260, height: 540)
        .environmentObject(AppState())
}
