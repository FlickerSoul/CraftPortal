//
//  LaunchSubTask.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/15/24.
//

import SwiftUICore

enum LaunchSubTask {
    case success
    case failed
    case step(LaunchSubTaskItem)
}

struct LaunchSubTaskItem {
    let name: LocalizedStringKey
    let icon: String

    init(name: LocalizedStringKey, icon: String = "checkmark.circle") {
        self.name = name
        self.icon = icon
    }
}
