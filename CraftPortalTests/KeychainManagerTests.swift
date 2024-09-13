//
//  KeychainManagerTests.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/6/24.
//

import Foundation
import Testing

@testable import CraftPortal

@Suite
class KeychainManagerTests {
    let testLabel: String = "TestKeychainManager"
    let testUUID = UUID()
    static let uniformUUID = UUID()

    func emptyQuery() throws {
        #expect(throws: KeychainError.self) {
            try KeychainManager.query(account: testUUID, label: testLabel)
        }
    }

    func delete() throws {
        try KeychainManager.delete(account: testUUID, label: testLabel)
    }

    @Test
    func testSetAndDelete() throws {
        let token = "test"

        #expect(throws: Never.self) {
            try KeychainManager.save(
                account: testUUID, token: token, label: testLabel
            )
            let result = try KeychainManager.query(
                account: testUUID, label: testLabel
            )
            #expect(result == token)
        }

        try delete()

        try emptyQuery()
    }

    @Test
    func testRepeatedSetAndDelete() throws {
        let token = "test"
        let secondToken = "second"

        #expect(throws: Never.self) {
            try KeychainManager.save(
                account: testUUID, token: token, label: testLabel
            )
            try KeychainManager.save(
                account: testUUID, token: secondToken, label: testLabel
            )

            let result = try KeychainManager.query(
                account: testUUID, label: testLabel
            )
            #expect(result == secondToken)
        }

        try delete()

        try emptyQuery()
    }

    @Test(
        "Test Saving Different Labels for Different Accounts",
        arguments: [
            (KeychainManager.minecraftTokenKey, "minecraft"),
            (KeychainManager.oAuthRefreshTokenKey, "refresh"),
            (KeychainManager.oAuthAccessTokenKey, "access"),
        ]
    )
    func testSave(label: String, value: String) throws {
        #expect(throws: Never.self) {
            try KeychainManager.save(
                account: testUUID, token: value, label: label
            )
        }

        let result = try KeychainManager.query(account: testUUID, label: label)
        #expect(result == value)

        try KeychainManager.delete(account: testUUID, label: label)
    }

    @Test(
        "Test Saving Multiple Labels for the Same Account",
        arguments: [
            (KeychainManager.minecraftTokenKey, "minecraft"),
            (KeychainManager.oAuthRefreshTokenKey, "refresh"),
            (KeychainManager.oAuthAccessTokenKey, "access"),
        ]
    )
    func testSaveToTheSameAccount(label: String, value: String) throws {
        #expect(throws: Never.self) {
            try KeychainManager.save(
                account: KeychainManagerTests.uniformUUID, token: value, label: label
            )
        }

        let result = try KeychainManager.query(account: KeychainManagerTests.uniformUUID, label: label)
        #expect(result == value)

        try KeychainManager.delete(account: KeychainManagerTests.uniformUUID, label: label)
    }

    @Test
    func testSaveFull() throws {
        let uuid = UUID()
        let credential = EssentialCredentials(
            oAuthAccessToken: "access",
            oAuthRefreshToken: "refresh",
            minecraftToken: "minecraft"
        )

        #expect(throws: Never.self) {
            try KeychainManager.saveFull(account: uuid, credential: credential)
        }

        let result = try KeychainManager.queryFull(account: uuid)
        #expect(result == credential)

        KeychainManager.deleteFull(account: uuid)
    }
}
