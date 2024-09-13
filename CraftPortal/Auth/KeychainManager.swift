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
    case unknownQueryError(for: String, status: OSStatus)
    case unknownSaveError(for: String, status: OSStatus)
    case unknownDeleteError(for: String, status: OSStatus)

    var description: String {
        switch self {
        case let .invalidData(for: key):
            return "Invalid data for key \(key)"
        case let .decodingError(for: key):
            return "Decoding error for key \(key)"
        case let .unknownSaveError(for: key, status):
            return "Unknown save error for key \(key): \(status)"
        case let .unknownDeleteError(for: key, status: status):
            return "Unknown delete error for key \(key): \(status)"
        case let .unknownQueryError(for: key, status: status):
            return "Unknown query error for key \(key): \(status)"
        }
    }
}

struct EssentialCredentials: Equatable {
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
        account: UUID, credential: EssentialCredentials
    ) throws {
        try save(
            account: account,
            token: credential.oAuthAccessToken,
            label: oAuthAccessTokenKey
        )
        try save(
            account: account,
            token: credential.oAuthRefreshToken,
            label: oAuthRefreshTokenKey
        )
        try save(
            account: account,
            token: credential.minecraftToken,
            label: minecraftTokenKey
        )
    }

    static func queryFull(account: UUID) throws -> EssentialCredentials {
        let oAuthAccessToken = try query(
            account: account, label: oAuthAccessTokenKey
        )
        let oAuthRefreshToken = try query(
            account: account, label: oAuthRefreshTokenKey
        )
        let minecraftToken = try query(
            account: account, label: minecraftTokenKey
        )

        return EssentialCredentials(
            oAuthAccessToken: oAuthAccessToken,
            oAuthRefreshToken: oAuthRefreshToken,
            minecraftToken: minecraftToken
        )
    }

    static func accountToKey(account: UUID, label: String) -> String {
        return "\(account.uuidString).\(label)"
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

        let key = accountToKey(account: account, label: label)

        let secQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrLabel as String: label,
            kSecValueData as String: data,
        ]

        SecItemDelete(secQuery as CFDictionary)

        let status = SecItemAdd(secQuery as CFDictionary, nil)

        if status != errSecSuccess {
            throw KeychainError.unknownSaveError(for: label, status: status)
        }
    }

    static func query(account: UUID, label: String) throws -> String {
        let key = accountToKey(account: account, label: label)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrLabel as String: label,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var dataTypeRef: CFTypeRef? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        switch status {
        case errSecSuccess:
            if let data = dataTypeRef as? Data {
                if let str = String(data: data, encoding: .utf8) {
                    return str
                } else {
                    throw KeychainError.decodingError(for: label)
                }
            } else {
                throw KeychainError.invalidData(for: label)
            }
        case _:
            throw KeychainError.unknownQueryError(for: label, status: status)
        }
    }

    static func delete(account: UUID, label: String) throws {
        let key = accountToKey(account: account, label: label)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrLabel as String: label,
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            throw KeychainError.unknownDeleteError(for: label, status: status)
        }
    }
}
