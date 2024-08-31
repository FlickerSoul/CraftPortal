//
//  FileChooser.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import SwiftUI
import UniformTypeIdentifiers

func chooseFolder(
    title: String = "Choose a Folder",
    message: String = "Please select a folder to use.",
    prompt: String = "Select"
) -> URL? {
    let openPanel = NSOpenPanel()

    openPanel.title = title
    openPanel.message = message
    openPanel.prompt = prompt

    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false
    openPanel.canCreateDirectories = true

    if openPanel.runModal() == .OK, let selectedFolder = openPanel.url {
        return selectedFolder
    } else {
        return nil
    }
}

func chooseFile(
    title: String = "Choose a File",
    message: String = "Please select a file to use.",
    prompt: String = "Select",
    fileTypes: [UTType]? = nil
) -> URL? {
    let openPanel = NSOpenPanel()

    openPanel.title = title
    openPanel.message = message
    openPanel.prompt = prompt

    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = false
    openPanel.canCreateDirectories = false
    openPanel.allowsMultipleSelection = false

    if let fileTypes {
        openPanel.allowedContentTypes = fileTypes
    }

    if openPanel.runModal() == .OK, let selectedFile = openPanel.url {
        return selectedFile
    } else {
        return nil
    }
}
