
//
//  Utils.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import AppKit
import Foundation
import Testing

@testable import CraftPortal

extension AppState {
    static var emptyAppStateFixture: AppState {
        .init()
    }
}

class AssetLoader {
    static var shared: AssetLoader = .init()

    func loadAssetData(name: String, ext: String, from subdir: String? = nil) throws -> Data {
        let bundle = Bundle(for: type(of: self))
        let url = try #require(bundle.url(forResource: name, withExtension: ext, subdirectory: subdir))
        let asset = try Data(contentsOf: url)

        return asset
    }

    func loadAssetFolder(name: String, from subdir: String) throws -> URL {
        let bundle = Bundle(for: type(of: self))
        let asset = try #require(bundle.url(forResource: name, withExtension: nil, subdirectory: subdir))

        return asset
    }

    func loadMinecraftMeta(name: String, from subdir: String? = nil) throws -> MinecraftMeta {
        let data = try loadAssetData(name: name, ext: "json", from: subdir)
        return try JSONDecoder().decode(MinecraftMeta.self, from: data)
    }

    private init() {}
}
