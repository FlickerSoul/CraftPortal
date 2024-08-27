
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

    func loadAssetData(name: String) throws -> Data {
        let bundle = Bundle(for: type(of: self))
        let asset = try #require(NSDataAsset(name: name, bundle: bundle))

        return asset.data
    }

    func loadMinecraftMeta(name: String) throws -> MinecraftMeta {
        let data = try loadAssetData(name: name)
        return try JSONDecoder().decode(MinecraftMeta.self, from: data)
    }

    private init() {}
}
