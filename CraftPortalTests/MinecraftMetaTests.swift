//
//  MinecraftMetaTests.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//

import Foundation
import Testing
import XCTest

@testable import CraftPortal

struct MinecraftMetaTests {
    @Test(
        "Test Minecraft Meta JSON Decoding",
        arguments: ["1.21", "1.21.1-fabric-0.16.3"]
    )
    func testJsonDecoding(name: String) throws {
        let data = try AssetLoader.shared.loadAssetData(name: name)

        let decoder = JSONDecoder()
        _ = try decoder.decode(MinecraftMeta.self, from: data)
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
