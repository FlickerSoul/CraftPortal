//
//  AppStateTests.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/27/24.
//

@testable import CraftPortal
import Testing
import XCTest

class AppStateTests: XCTestCase {
    var appState: AppState!

    override func setUp() {
        appState = AppState()
    }

    @Test
    func testAppVersion() {
        let expectedVersion = "1.0 (1)"

        XCTAssertEqual(appState.appVersion, expectedVersion)
    }
}
