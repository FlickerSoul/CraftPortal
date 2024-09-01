//
//  MinecraftMetaTests.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//

import Foundation
import Testing

@testable import CraftPortal

struct MinecraftMetaTests {
    @Test(
        "Test Minecraft Meta JSON Decoding",
        arguments: [
            ("1.21", "Assets/ProfiledVanillaGame/meta/versions/1.21"),
            ("24w35a", "Assets/ProfiledVanillaGame/meta/versions/24w35a"),
            ("1.21", "Assets/ProfiledModdedGame/meta/versions/1.21"),
            ("1.21.1-fabric-0.16.3", "Assets/ProfiledModdedGame/meta/versions/1.21.1-fabric-0.16.3"),
        ]
    )
    func testFullJsonDecoding(name: String, from dir: String) throws {
        let data = try AssetLoader.shared.loadAssetData(name: name, ext: "json", from: dir)

        let decoder = JSONDecoder()
        _ = try decoder.decode(MinecraftMeta.self, from: data)
    }

    @Test(
        "Test Minecraft Meta Inheritance JSON Decoding",
        arguments: [
            ("fabric-loader-0.15.11-1.21", "Assets/ModdedGameWithInheritedMeta/versions/fabric-loader-0.15.11-1.21"),
        ]
    )
    func testInheritanceJsonDecoding(name: String, from dir: String) throws {
        let data = try AssetLoader.shared.loadAssetData(name: name, ext: "json", from: dir)

        let decoder = JSONDecoder()

        _ = try decoder.decode(MinecraftInheritsMeta.self, from: data)
    }

    enum MetaType {
        case full
        case inherits
    }

    @Test(
        "Test Minecraft Metadata Enum Decoding",
        arguments: [
            ("1.21", "Assets/ProfiledVanillaGame/meta/versions/1.21", MetaType.full),
            ("24w35a", "Assets/ProfiledVanillaGame/meta/versions/24w35a", MetaType.full),
            ("1.21", "Assets/ProfiledModdedGame/meta/versions/1.21", MetaType.full),
            ("1.21.1-fabric-0.16.3", "Assets/ProfiledModdedGame/meta/versions/1.21.1-fabric-0.16.3", MetaType.full),
            ("fabric-loader-0.15.11-1.21", "Assets/ModdedGameWithInheritedMeta/versions/fabric-loader-0.15.11-1.21", MetaType.inherits),
        ]
    )
    func testMetadataEnumDecoding(name: String, from dir: String, type: MetaType) throws {
        let data = try AssetLoader.shared.loadAssetData(name: name, ext: "json", from: dir)
        let decoder = JSONDecoder()

        let metadata = try decoder.decode(MinecraftMetadata.self, from: data)

        if case .full = metadata {
            #expect(type == .full)
        } else if case .inherits = metadata {
            #expect(type == .inherits)
        }
    }

    @Test
    func testArgumentItemDecoding() throws {
        let json = """
              {
                "rules": [
                  {
                    "action": "allow",
                    "os": {
                      "name": "osx"
                    }
                  }
                ],
                "value": [
                  "-XstartOnFirstThread"
                ]
              }
        """
        let arg = try JSONDecoder().decode(
            MinecraftMetaArgumentElement.self,
            from: json.data(using: .utf8)!
        )
        if case let .complexArgument(arg) = arg {
            #expect(arg.rules.count == 1)
            let rule = arg.rules.first!
            #expect(rule.os != nil)
            #expect(rule.os!.isValidOS)
        }
    }
}
