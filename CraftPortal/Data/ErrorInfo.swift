//
//  ErrorInfo.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/8/24.
//
import Foundation
import SwiftUICore

struct ErrorCallback {
    let buttonName: LocalizedStringKey
    let callback: () -> Void
}

/// Error information used to display prompts to users
struct ErrorInfo: Identifiable {
    let id: UUID = .init()
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    var callbacks: [ErrorCallback] = []

    init(title: LocalizedStringKey, description: LocalizedStringKey, callback: ErrorCallback? = nil) {
        self.title = title
        self.description = description
        if let callback {
            callbacks = [callback]
        }
    }
}

extension ErrorInfo: Equatable {
    static func == (lhs: ErrorInfo, rhs: ErrorInfo) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
            && lhs.description == rhs.description
    }
}
