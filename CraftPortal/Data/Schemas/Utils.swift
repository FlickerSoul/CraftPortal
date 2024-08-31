//
//  Utils.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//

protocol FullVersion {
    var fullVersion: String { get }
}

/// An enum represeting the mod loader used in the game
enum ModLoader: Codable, FullVersion {
    case Forge(major: Int, minor: Int, patch: Int)
    case NeoForge(major: Int, minor: Int, patch: Int)
    case Fabric(major: Int, minor: Int, patch: Int)
    case Quilt(major: Int, minor: Int, patch: Int)

    var fullVersion: String {
        switch self {
        case let .Forge(major, minor, patch):
            return "forge-\(major).\(minor).\(patch)"
        case let .NeoForge(major, minor, patch):
            return "neoforge-\(major).\(minor).\(patch)"
        case let .Fabric(major, minor, patch):
            return "fabric-\(major).\(minor).\(patch)"
        case let .Quilt(major, minor, patch):
            return "quilt-\(major).\(minor).\(patch)"
        }
    }
}

/// An enum represeting the versions of the game
enum GameVersion: Codable, FullVersion {
    case Release(major: Int, minor: Int, patch: Int? = nil)
    case Snapshot(version: String)
    case Historical(major: Int, minor: Int, patch: Int)

    var fullVersion: String {
        switch self {
        case let .Release(major, minor, patch):
            return "\(major).\(minor)" + (patch.map { ".\($0)" } ?? "")
        case let .Snapshot(version):
            return version
        case let .Historical(major, minor, patch):
            return "\(major).\(minor).\(patch)"
        }
    }

    var versionType: String {
        switch self {
        case .Release: "release"
        case .Snapshot: "snapshot"
        case .Historical: "historical"
        }
    }
}

/// An enum representing the user profile type
enum UserAccountType: Codable {
    case Local
    case MSA
}

/// An enum represeting the game directory type: how game directory is structured
enum GameDirectoryType: Codable, CaseIterable, Equatable, Identifiable {
    case Mangled
    case Profile

    var id: String {
        switch self {
        case .Mangled: return "mangled"
        case .Profile: return "profile"
        }
    }
}
