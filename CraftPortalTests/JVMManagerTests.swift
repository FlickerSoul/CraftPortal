//
//  JVMManagerTests.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/29/24.
//

import Foundation
import Testing

@testable import CraftPortal

@Suite
struct JVMInformationTest {
    @Test("Test JVM Major Version Parsing", arguments: [
        ("1.1", 1),
        ("1.2", 2),
        ("1.3", 3),
        ("1.5", 5),
        ("1.6", 6),
        ("1.7", 7),
        ("1.8", 8),
        ("1.8.0_422", 8),
        ("9.0", 9),
        ("10.0", 10),
        ("17.0.11", 17),
        ("21.0.4", 21),
        ("22.0.2", 22),
    ])
    func testMajorVersion(fullVersion: String, expectedMajor: Int) {
        let info = JVMInformation(path: "", version: fullVersion)
        #expect(info.majorVersion == expectedMajor)
    }
}

@Suite("JVM Manager Tests", .enabled(if: ProcessInfo.processInfo.environment["TEST_JVM_MANAGER"] == "1"))
struct JVMManagerTests {
    @Test
    func testJVMManagerDiscover() {
        let manager = JVMManager()
        manager.discover().forEach { print($0) }
    }
}
