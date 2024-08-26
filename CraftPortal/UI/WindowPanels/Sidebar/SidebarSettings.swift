//
//  SidebarSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//
import SwiftUI

struct SidebarSettings: View {
    var body: some View {
        SidebarItemChip(imageSource: .systemIcon(name: "gear")) {
            Text("Global Settings")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}
