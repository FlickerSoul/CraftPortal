//
//  AppStateTests.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/27/24.
//

import Testing

@testable import CraftPortal

@Test
func testAppVersion() {
    let expectedVersion = "1.0 (1)"

    #expect(AppState.appVersion == expectedVersion)
}
