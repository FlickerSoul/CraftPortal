//
//  ErrorInfo.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/8/24.
//
import Foundation

struct ErrorCallback {
    let buttonName: String
    let callback: () -> Void
}

/// Error information used to display prompts to users
struct ErrorInfo: Identifiable {
    let id: UUID = .init()
    let title: String
    let description: String
    var callbacks: [ErrorCallback] = []

    init(title: String, description: String, callback: ErrorCallback? = nil) {
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
