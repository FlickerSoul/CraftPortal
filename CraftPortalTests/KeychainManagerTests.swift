//
//  KeychainManagerTests.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/6/24.
//

@testable import CraftPortal
import Foundation
import Testing

@Suite
class KeychainManagerTests {
    let testLabel: String = "TestKeychainManager"
    let testUUID = UUID()

    @Test
    func test() throws {
        let token = "test"
        try KeychainManager.save(account: testUUID, token: token, label: testLabel)
        let result = try KeychainManager.query(account: testUUID, label: testLabel)
        #expect(result == token)
        try KeychainManager.delete(account: testUUID, label: testLabel)

        var flag = false

        do {
            let string = try KeychainManager.query(account: testUUID, label: testLabel)
        } catch {
            flag = true
        }

        #expect(flag)
    }
}
