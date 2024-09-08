//
//  ErrorInfo.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/8/24.
//
import Foundation

/// Error information used to display prompts to users
struct ErrorInfo: Identifiable, Equatable {
    let id: UUID = .init()
    let title: String
    let description: String
}
