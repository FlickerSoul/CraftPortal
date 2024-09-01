//
//  URL+.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/1/24.
//
import Foundation
import Path

extension URL {
    func toPath() -> Path? {
        Path(path(percentEncoded: false))
    }
}
