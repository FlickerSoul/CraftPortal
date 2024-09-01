//
//  MinecraftMeta.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//
import Foundation

struct MinecraftMetaArguments: Codable {
    fileprivate(set) var game: [MinecraftMetaArgumentElement]?
    fileprivate(set) var jvm: [MinecraftMetaArgumentElement]?
}

enum MinecraftMetaArgumentElement: Codable {
    case string(String)
    case complexArgument(MinecraftMetaComplexArgument)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let complexValue = try? container.decode(
            MinecraftMetaComplexArgument.self)
        {
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

enum StringOrStringArray: Codable, Sequence {
    case single(String)
    case multiple([String])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let singleValue = try? container.decode(String.self) {
            self = .single(singleValue)
        } else if let multipleValues = try? container.decode([String].self) {
            self = .multiple(multipleValues)
        } else {
            throw DecodingError.typeMismatch(StringOrStringArray.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected a String or an array of Strings"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .single(value):
            try container.encode(value)
        case let .multiple(values):
            try container.encode(values)
        }
    }

    func makeIterator() -> IndexingIterator<[String]> {
        switch self {
        case let .single(value):
            return [value].makeIterator()
        case let .multiple(values):
            return values.makeIterator()
        }
    }
}

struct MinecraftMetaComplexArgument: Codable {
    let rules: [MinecraftMetaRule]
    let value: StringOrStringArray
}

extension [MinecraftMetaRule] {
    func allSatisfy(by features: LaunchFeatureCollection) -> Bool {
        return allSatisfy { rule in
            let ruleSat =
                rule.features?
                    .map { key, val in (key, val) }
                    .allSatisfy {
                        key, value in
                        guard let featValue = features[key] else {
                            return false
                        }
                        return featValue == value
                    } ?? true
            let osSat = rule.os?.isValidOS ?? true

            return ruleSat && osSat
        }
    }
}

enum MinecraftMetaRuleAction: String, Codable {
    case allow
}

struct MinecraftMetaRule: Codable {
    let action: MinecraftMetaRuleAction
    let features: [String: Bool?]?
    let os: MinecraftMetaOS?
}

struct MinecraftMetaOS: Codable {
    let name: String?
    let arch: String?

    var isValidOS: Bool {
        return name == "osx"
    }
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

// struct MinecraftMetaPatch: Codable {
//    let id: String
//    let version: String
//    let priority: Int
//    let arguments: MinecraftMetaArguments
//    let mainClass: String
//    let assetIndex: MinecraftMetaAssetIndex?
//    let assets: String?
//    let complianceLevel: Int?
//    let javaVersion: MinecraftMetaJavaVersion?
//    let libraries: [MinecraftMetaLibrary]
// }

struct MinecraftMeta: Codable {
    private(set) var id: String
    private(set) var arguments: MinecraftMetaArguments
    private(set) var mainClass: String
    private(set) var jar: String?
    private(set) var mcVersion: String?
    private(set) var assetIndex: MinecraftMetaAssetIndex
    private(set) var assets: String
    private(set) var javaVersion: MinecraftMetaJavaVersion
    private(set) var libraries: [MinecraftMetaLibrary]
    private(set) var downloads: MinecraftMetaDownloads
    private(set) var logging: MinecraftMetaLogging?
    private(set) var type: String
    private(set) var time: String
    private(set) var releaseTime: String
    private(set) var minimumLauncherVersion: Int
    private(set) var root: Bool?
    // let patches: [MinecraftMetaPatch]?

    func patch(with patch: MinecraftInheritsMeta) -> MinecraftMeta {
        var patched = self
        patched.mainClass = patch.mainClass
        patched.libraries.append(contentsOf: patch.libraries)
        patched.arguments.jvm = (patch.arguments.jvm ?? []) + (patch.arguments.jvm ?? [])
        patched.arguments.game = (patch.arguments.game ?? []) + (patch.arguments.game ?? [])
        patched.mcVersion = patch.inheritsFrom
        patched.type = patch.type

        return patched
    }
}

struct MinecraftInheritsMeta: Codable {
    let id: String
    let inheritsFrom: String
    let mainClass: String
    let libraries: [MinecraftMetaLibrary]
    let arguments: MinecraftMetaArguments
    let type: String
}

enum MinecraftMetadata: Codable {
    case full(MinecraftMeta)
    case inherits(MinecraftInheritsMeta)

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.inheritsFrom) {
            // If the JSON contains "inheritsFrom", we decode as `MinecraftInheritsMeta`
            let inheritsMeta = try MinecraftInheritsMeta(from: decoder)
            self = .inherits(inheritsMeta)
        } else {
            // Otherwise, decode as `MinecraftMeta`
            let fullMeta = try MinecraftMeta(from: decoder)
            self = .full(fullMeta)
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case let .full(minecraftMeta):
            try minecraftMeta.encode(to: encoder)
        case let .inherits(minecraftInheritsMeta):
            try minecraftInheritsMeta.encode(to: encoder)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case inheritsFrom
    }
}
