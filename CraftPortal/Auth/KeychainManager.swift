//
//  KeychainManager.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/5/24.
//
import Foundation

enum KeychainError: Error {
    case invalidData(for: String)
    case decodingError(for: String)
    case unknownError(for: String, status: OSStatus)
}

struct EssentialCredentials {
    let oAuthAccessToken: String
    let oAuthRefreshToken: String
    let minecraftToken: String
}

struct KeychainManager {
    private init() {}

    static let service: String = "observer.universe.CraftPortal"
    static let oAuthAccessTokenKey: String = "OAuthAccessToken"
    static let oAuthRefreshTokenKey: String = "OAuthRefreshToken"
    static let minecraftTokenKey: String = "MinecraftToken"

    static func saveFull(
        account: UUID, oAuthAccessToken: String, oAuthRefreshToken: String,
        minecraftToken: String
    ) throws {
        try save(account: account, token: oAuthAccessToken, label: oAuthAccessTokenKey)
        try save(account: account, token: oAuthRefreshToken, label: oAuthRefreshTokenKey)
        try save(account: account, token: minecraftToken, label: minecraftTokenKey)
    }

    static func queryFull(account: UUID) throws -> EssentialCredentials {
        let oAuthAccessToken = try query(account: account, label: oAuthAccessTokenKey)
        let oAuthRefreshToken = try query(account: account, label: oAuthRefreshTokenKey)
        let minecraftToken = try query(account: account, label: minecraftTokenKey)

        return EssentialCredentials(
            oAuthAccessToken: oAuthAccessToken,
            oAuthRefreshToken: oAuthRefreshToken,
            minecraftToken: minecraftToken
        )
    }

    static func deleteFull(account: UUID) {
        try? delete(account: account, label: oAuthAccessTokenKey)
        try? delete(account: account, label: oAuthRefreshTokenKey)
        try? delete(account: account, label: minecraftTokenKey)
    }

    static func save(account: UUID, token: String, label: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.invalidData(for: label)
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrLabel as String: label,
            kSecValueData as String: data,
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            throw KeychainError.unknownError(for: label, status: status)
        }
    }

    static func query(account: UUID, label: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrLabel as String: label,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                if let str = String(data: data, encoding: .utf8) {
                    return str
                } else {
                    throw KeychainError.decodingError(for: label)
                }
            } else {
                throw KeychainError.invalidData(for: label)
            }
        } else {
            throw KeychainError.unknownError(for: label, status: status)
        }
    }

    static func delete(account: UUID, label: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrLabel as String: label,
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            throw KeychainError.unknownError(for: label, status: status)
        }
    }
}
