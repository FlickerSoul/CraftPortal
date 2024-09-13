//
//  Copy.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/10/24.
//
import Cocoa

func copyText(_ text: String) {
    let clipboard = NSPasteboard.general
    clipboard.clearContents()
    clipboard.setString(text, forType: .string)
}
