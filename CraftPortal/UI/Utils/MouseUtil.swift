//
//  MouseUtil.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import SwiftUI

struct HoverCursorModifier: ViewModifier {
    let cursor: NSCursor

    func body(content: Content) -> some View {
        content
            .onHover { isHovering in
                if isHovering {
                    cursor.push()
                } else {
                    NSCursor.pop()
                }
            }
    }
}

extension View {
    func hoverCursor(_ cursor: NSCursor = .pointingHand) -> some View {
        modifier(HoverCursorModifier(cursor: cursor))
    }
}
