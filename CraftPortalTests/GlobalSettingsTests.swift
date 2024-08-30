//
//  GlobalSettingsTests.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/30/24.
//

import Testing

@testable import CraftPortal

@Suite
struct GlobalSettingsTests {
    @Test
    func testGlobalSettingsUpdateAndRetrieved() throws {
        let manager = GlobalSettingsManager()
        let keyPath: WritableKeyPath<GlobalSettings, UInt> =
            \.globalGameSettings.dynamicMemory
        let changedVal: UInt = 100

        var saved = false

        manager.change(
            keyPath: keyPath, value: changedVal,
            onComplete: {
                saved = true
            }
        )

        while !saved {}

        let loaded = try #require(GlobalSettingsManager.loadSettings())

        #expect(loaded[keyPath: keyPath] == changedVal)
    }
}
