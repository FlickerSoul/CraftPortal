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

class MinecraftMetaTests: XCTestCase {
    @Test(
        "Test Minecraft Meta JSON Decoding",
        arguments: ["1.21", "1.21.1-fabric-0.16.3"]
    )
    func testJsonDecoding(name: String) throws {
        guard
            let url = Bundle(for: type(of: self)).url(
                forResource: name, withExtension: "json"
            )
        else {
            XCTFail("Cannot find \(name).json")
            return
        }

        guard let data = try? Data(contentsOf: url) else {
            XCTFail()
            return
        }

        let decoder = JSONDecoder()
        _ = try decoder.decode(MinecraftMeta.self, from: data)
    }
}
