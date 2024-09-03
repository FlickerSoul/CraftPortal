//
//  AdvancedSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/1/24.
//
import Foundation
import SwiftData

enum AdditionalJVMArguments: Codable {
    case defaulted
    case custom([String])

    init(fromString: String) {
        let trimmedString = fromString.trimmingCharacters(
            in: .whitespacesAndNewlines)
        if trimmedString.isEmpty {
            self = .defaulted
        } else {
            let args = trimmedString.split(separator: " ").map { arg in
                arg.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            self = .custom(args)
        }
    }

    private static func defaultJVMArguments() -> Set<String> {
        return [
            "-Dfile.encoding=UTF-8",
            "-Dstdout.encoding=UTF-8",
            "-Dstderr.encoding=UTF-8",
            "-XX:+UnlockExperimentalVMOptions",
            "-XX:+UseG1GC",
            "-XX:G1NewSizePercent=20",
            "-XX:G1ReservePercent=20",
            "-XX:MaxGCPauseMillis=50",
            "-Dfml.ignoreInvalidMinecraftCertificates=true",
        ]
    }

    func arguments() -> Set<String> {
        switch self {
        case .defaulted: return Self.defaultJVMArguments()
        case let .custom(args): return Set(args)
        }
    }
}

extension CraftPortalSchemaV1 {
    @Model
    class AdvancedJVMSettings: Codable, ObservableObject {
        var additionalJVMArguments: AdditionalJVMArguments =
            AdditionalJVMArguments.defaulted
        var disableDefaultJVMArguments: Bool = false

        init(
            additionalJVMArguments: AdditionalJVMArguments = .defaulted,
            disableDefaultJVMArguments: Bool = false
        ) {
            self.additionalJVMArguments = additionalJVMArguments
            self.disableDefaultJVMArguments = disableDefaultJVMArguments
        }

        func composeAdditionalJVMArguments() -> Set<String> {
            var args: Set<String> =
                disableDefaultJVMArguments
                    ? [] : AdditionalJVMArguments.defaulted.arguments()

            switch additionalJVMArguments {
            case let .custom(customArgs):
                args.formUnion(customArgs)
            case _:
                break
            }

            return args
        }

        enum CodingKeys: String, CodingKey {
            case _additionalJVMArguments = "additionalJVMArguments"
            case _disableDefaultJVMArguments = "disableDefaultJVMArguments"
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            additionalJVMArguments = try container.decode(
                AdditionalJVMArguments.self, forKey: ._additionalJVMArguments
            )
            disableDefaultJVMArguments = try container.decode(
                Bool.self, forKey: ._disableDefaultJVMArguments
            )
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(
                additionalJVMArguments, forKey: ._additionalJVMArguments
            )
            try container.encode(
                disableDefaultJVMArguments, forKey: ._disableDefaultJVMArguments
            )
        }
    }

    @Model
    class AdvancedWorkaroundSettings: Codable, ObservableObject {
        var disableGameIntegratyCheck: Bool = false
        var disableJVMCompatibilityCheck: Bool = false

        init(
            disableGameIntegratyCheck: Bool = false,
            disableJVMCompatibilityCheck: Bool = false
        ) {
            self.disableGameIntegratyCheck = disableGameIntegratyCheck
            self.disableJVMCompatibilityCheck = disableJVMCompatibilityCheck
        }

        enum CodingKeys: String, CodingKey {
            case _disableGameIntegratyCheck = "disableGameIntegratyCheck"
            case _disableJVMCompatibilityCheck = "disableJVMCompatibilityCheck"
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            disableGameIntegratyCheck = try container.decode(
                Bool.self, forKey: ._disableGameIntegratyCheck
            )
            disableJVMCompatibilityCheck = try container.decode(
                Bool.self, forKey: ._disableJVMCompatibilityCheck
            )
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(
                disableGameIntegratyCheck, forKey: ._disableGameIntegratyCheck
            )
            try container.encode(
                disableJVMCompatibilityCheck,
                forKey: ._disableJVMCompatibilityCheck
            )
        }
    }

    @Model
    class AdvancedSettings: Codable, ObservableObject {
        var jvm: AdvancedJVMSettings
        var workaround: AdvancedWorkaroundSettings

        init(
            jvm: AdvancedJVMSettings = .init(),
            workaround: AdvancedWorkaroundSettings = .init()
        ) {
            self.jvm = jvm
            self.workaround = workaround
        }

        enum CodingKeys: String, CodingKey {
            case _jvm = "jvm"
            case _workaround = "workaround"
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            jvm = try container.decode(AdvancedJVMSettings.self, forKey: ._jvm)
            workaround = try container.decode(
                AdvancedWorkaroundSettings.self, forKey: ._workaround
            )
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(jvm, forKey: ._jvm)
            try container.encode(workaround, forKey: ._workaround)
        }
    }
}
