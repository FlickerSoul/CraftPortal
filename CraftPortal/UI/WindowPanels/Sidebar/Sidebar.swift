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

            Spacer()

            SidebarHome()
        }
    }
}

#Preview {
    Sidebar(updatePanel: { _ in })
        .frame(width: 260, height: 540)
        .environmentObject(AppState())
}
