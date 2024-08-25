//
//  ImageSource.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//

enum ImageSource {
    case asset(name: String)
    case file(path: String)
    case systemIcon(name: String)
}
