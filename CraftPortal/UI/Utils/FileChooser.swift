//
//  FileChooser.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import Cocoa

func chooseFolder() -> URL? {
    let openPanel = NSOpenPanel()

    openPanel.title = "Choose a Folder"
    openPanel.message = "Please select a folder to use."
    openPanel.prompt = "Select"

    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false
    openPanel.canCreateDirectories = false

    if openPanel.runModal() == .OK, let selectedFolder = openPanel.url {
        return selectedFolder
    } else {
        return nil
    }
}
