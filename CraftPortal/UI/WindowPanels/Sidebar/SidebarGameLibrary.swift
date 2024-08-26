//
//  SidebarGameSelection.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//
import SwiftUI

struct SidebarGameLibrary: View {
    var body: some View {
        SidebarItemChip(imageSource: .systemIcon(name: "building.columns.fill")) {
            Text("Game Library")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}
