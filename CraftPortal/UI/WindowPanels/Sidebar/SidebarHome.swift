//
//  SidebarHome.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//

import SwiftUI

struct SidebarHome: View {
    var body: some View {
        SidebarItemChip(imageSource: .systemIcon(name: "house")) {
            Text("Home")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    SidebarHome()
}
