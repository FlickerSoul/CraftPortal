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
    case Forge(String)
    case NeoForge(String)
    case Fabric(String)
    case Quilt(String)

    var fullVersion: String {
        switch self {
        case let .Forge(version):
            return "forge-\(version)"
        case let .NeoForge(version):
            return "neoforge-\(version)"
        case let .Fabric(version):
            return "fabric-\(version)"
        case let .Quilt(version):
            return "quilt-\(version)"
        }
    }

    static func fromFullMeta(_ meta: MinecraftMeta) -> ModLoader? {
        from(ibraries: meta.libraries, arguments: meta.arguments)
    }

    static func fromInheritedMeta(_ meta: MinecraftInheritsMeta) -> ModLoader? {
        return from(ibraries: meta.libraries, arguments: meta.arguments)
    }

    static func from(ibraries: [MinecraftMetaLibrary], arguments: MinecraftMetaArguments) -> ModLoader? {
        for lib in ibraries {
            if lib.name.hasPrefix("net.fabricmc:fabric-loader") {
                let modVersion = lib.name.split(separator: ":").last!
                return .Fabric(String(modVersion))
            } else if lib.name.hasPrefix("net.minecraftforge:fmlloader") {
                let clientAndModVersion = lib.name.split(separator: ":").last!
                let modVersion = clientAndModVersion.split(separator: "-").last!
                return .Forge(String(modVersion))
            } else if lib.name.hasPrefix("org.quiltmc:quilt-loader") {
                let modVersion = lib.name.split(separator: ":").last!
                return .Quilt(String(modVersion))
            }
        }

        let neoForgeVerIndicatorIndex = arguments.game?.firstIndex(where: {
            if case let .string(str) = $0 {
                return str == "--fml.neoForgeVersion"
            }

            return false
        })

        if let neoForgeVerIndicatorIndex,
           let arg = arguments.game?[neoForgeVerIndicatorIndex + 1],
           case let .string(neoForgeVersion) = arg
        {
            return .NeoForge(neoForgeVersion)
        }

        return nil
    }
}

/// An enum represeting the versions of the game
enum GameVersion: Codable, FullVersion {
    case Release(String)
    case Snapshot(String)
    case Historical(String)

    var fullVersion: String {
        switch self {
        case let .Release(version), let .Snapshot(version),
             let .Historical(version):
            return version
        }
    }

    var versionType: String {
        switch self {
        case .Release: "release"
        case .Snapshot: "snapshot"
        case .Historical: "historical"
        }
    }

    init?(type: String, version: String) {
        switch type {
        case "release": self = .Release(version)
        case "snapshot": self = .Snapshot(version)
        case "historical": self = .Historical(version)
        default: return nil
        }
    }
}

/// An enum representing the user profile type
enum UserAccountType: Codable {
    case Local
    case MSA

    var string: String {
        switch self {
        case .Local: return "Local Account"
        case .MSA: return "Microsoft Account"
        }
    }
}

/// An enum represeting the game directory type: how game directory is structured
enum GameDirectoryType: Int, Codable, CaseIterable, Equatable, Identifiable {
    case Mangled
    case Profile

    var id: String {
        switch self {
        case .Mangled: return "mangled"
        case .Profile: return "profile"
        }
    }
}
