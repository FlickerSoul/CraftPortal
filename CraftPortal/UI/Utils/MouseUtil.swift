//
//  MouseUtil.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import SwiftUI

func changeMouseHovering(_ isHovered: Bool) {
    if isHovered {
        NSCursor.pointingHand.push()
    } else {
        NSCursor.pop()
    }
}
