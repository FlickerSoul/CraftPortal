//
//  MinecraftMeta.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import Foundation

struct MinecraftMetaArguments: Codable {
    let game: [MinecraftMetaArgumentElement]?
    let jvm: [MinecraftMetaArgumentElement]?
}

enum MinecraftMetaArgumentElement: Codable {
    case string(String)
    case complexArgument(MinecraftMetaComplexArgument)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let complexValue = try? container.decode(MinecraftMetaComplexArgument.self) {
            self = .complexArgument(complexValue)
        } else {
            throw DecodingError.typeMismatch(
                MinecraftMetaArgumentElement.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Mismatched type"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(value):
            try container.encode(value)
        case let .complexArgument(value):
            try container.encode(value)
        }
    }
}

struct MinecraftMetaComplexArgument: Codable {
    let rules: [MinecraftMetaRule]
    let value: [String]
}

struct MinecraftMetaRule: Codable {
    let action: String
    let features: MinecraftMetaFeatures?
    let os: MinecraftMetaOS?
}

struct MinecraftMetaFeatures: Codable {
    let isDemoUser: Bool?
    let hasCustomResolution: Bool?
    let hasQuickPlaysSupport: Bool?
    let isQuickPlaySingleplayer: Bool?
    let isQuickPlayMultiplayer: Bool?
    let isQuickPlayRealms: Bool?
}

struct MinecraftMetaOS: Codable {
    let name: String
    let arch: String?
}

struct MinecraftMetaAssetIndex: Codable {
    let totalSize: Int
    let id: String
    let url: String
    let sha1: String
    let size: Int
}

struct MinecraftMetaJavaVersion: Codable {
    let component: String
    let majorVersion: Int
}

struct MinecraftMetaLibrary: Codable {
    let name: String
    let url: String?
    let downloads: MinecraftMetaDownloadsArtifact?
    let rules: [MinecraftMetaRule]?
}

struct MinecraftMetaDownloads: Codable {
    let client: MinecraftMetaDownloadItem
    let server: MinecraftMetaDownloadItem?
    let serverMappings: MinecraftMetaDownloadItem?
    let clientMappings: MinecraftMetaDownloadItem?
}

struct MinecraftMetaDownloadItem: Codable {
    let url: String
    let sha1: String
    let size: Int
}

struct MinecraftMetaDownloadsArtifact: Codable {
    let artifact: MinecraftMetaArtifact
}

struct MinecraftMetaArtifact: Codable {
    let path: String
    let url: String
    let sha1: String
    let size: Int
}

struct MinecraftMetaLogging: Codable {
    let client: MinecraftMetaLoggingClient
}

struct MinecraftMetaLoggingClient: Codable {
    let file: MinecraftMetaLoggingFile
    let argument: String
    let type: String
}

struct MinecraftMetaLoggingFile: Codable {
    let id: String
    let url: String
    let sha1: String
    let size: Int
}

struct MinecraftMetaPatch: Codable {
    let id: String
    let version: String
    let priority: Int
    let arguments: MinecraftMetaArguments
    let mainClass: String
    let assetIndex: MinecraftMetaAssetIndex?
    let assets: String?
    let complianceLevel: Int?
    let javaVersion: MinecraftMetaJavaVersion?
    let libraries: [MinecraftMetaLibrary]
}

struct MinecraftMeta: Codable {
    let id: String
    let arguments: MinecraftMetaArguments
    let mainClass: String
    let jar: String
    let assetIndex: MinecraftMetaAssetIndex
    let assets: String
    let javaVersion: MinecraftMetaJavaVersion
    let libraries: [MinecraftMetaLibrary]
    let downloads: MinecraftMetaDownloads
    let logging: MinecraftMetaLogging?
    let type: String
    let time: String
    let releaseTime: String
    let minimumLauncherVersion: Int
    let root: Bool?
    let patches: [MinecraftMetaPatch]?
}
