//
//  SidebarHome.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//

import SwiftUI

struct SidebarHome: View {
    var body: some View {
        noSelection
    }

    var noSelection: some View {
        SidebarItemChip(imageSource: .asset(name: "NoGameProfileDefaultIcon")) {
            Text("No Game Selected")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    SidebarHome()
}
