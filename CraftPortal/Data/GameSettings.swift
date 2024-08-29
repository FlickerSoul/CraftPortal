//
//  GameSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/27/24.
//

enum Resolution: Codable {
    case fullscreen
    case window(width: UInt, height: UInt)
}

enum ProcessPriority: Int, Codable {
    case low = 5
    case belowNormal = 1
    case normal = 0
    case aboveNormal = -1
    case high = -5
}

enum AdditionalJVMArguments: Codable {
    case defaulted
    case custom(Set<String>)

    init(fromString: String) {
        let trimmedString = fromString.trimmingCharacters(
            in: .whitespacesAndNewlines)
        if trimmedString.isEmpty {
            self = .defaulted
        } else {
            let args = Set(
                trimmedString.split(separator: " ").map { arg in
                    arg.trimmingCharacters(in: .whitespacesAndNewlines)
                })

            self = .custom(args)
        }
    }

    private static let defaultJVMArguments: Set<String> = [
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

    func arguments() -> Set<String> {
        switch self {
        case .defaulted: return Self.defaultJVMArguments
        case let .custom(args): return args
        }
    }
}

struct JVMAdvancedSettings: Codable {
    var additionalJVMArguments: AdditionalJVMArguments = .defaulted
    var disableDefaultJVMArguments: Bool = false

    var formattedAdditionalJVMArguments: String {
        var args: Set<String> = disableDefaultJVMArguments ? [] : AdditionalJVMArguments.defaulted.arguments()

        switch additionalJVMArguments {
        case let .custom(customArgs):
            args.formUnion(customArgs)
        case _:
            break
        }

        return args.joined(separator: " ")
    }
}

struct AdvancedWorkaroundSettings: Codable {
    var disableGameIntegratyCheck: Bool = false
    var disableJVMCompatibilityCheck: Bool = false
}

struct AdvancedSettings: Codable {
    var jvm: JVMAdvancedSettings = .init()
    var workaround: AdvancedWorkaroundSettings = .init()
}

struct GameSettings: Codable {
    var dynamicMemory: UInt
    var resolution: Resolution
    var processPriority: ProcessPriority
    var advanced: AdvancedSettings
}
