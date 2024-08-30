//
//  GameSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/27/24.
//
import CoreGraphics
import Foundation

enum Resolution: Codable {
    case fullscreen
    case window(width: UInt, height: UInt)

    func toSizeStrings() -> (width: String, height: String) {
        switch self {
        case .fullscreen:
            return ("", "")
        case let .window(width: width, height: height):
            return (String(width), String(height))
        }
    }
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

@Observable
class JVMAdvancedSettings: Codable {
    var additionalJVMArguments: AdditionalJVMArguments = .defaulted
    var disableDefaultJVMArguments: Bool = false

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
}

@Observable
class AdvancedWorkaroundSettings: Codable {
    var disableGameIntegratyCheck: Bool = false
    var disableJVMCompatibilityCheck: Bool = false

    enum CodingKeys: String, CodingKey {
        case _disableGameIntegratyCheck = "disableGameIntegratyCheck"
        case _disableJVMCompatibilityCheck = "disableJVMCompatibilityCheck"
    }
}

@Observable
class AdvancedSettings: Codable {
    var jvm: JVMAdvancedSettings = .init()
    var workaround: AdvancedWorkaroundSettings = .init()

    enum CodingKeys: String, CodingKey {
        case _jvm = "jvm"
        case _workaround = "workaround"
    }
}

@Observable
class GameSettings: Codable {
    var dynamicMemory: UInt
    var resolution: Resolution
    var processPriority: ProcessPriority
    var advanced: AdvancedSettings

    init(
        dynamicMemory: UInt? = nil, resolution: Resolution? = nil,
        processPriority: ProcessPriority = .normal,
        advanced: AdvancedSettings = .init()
    ) {
        self.dynamicMemory = dynamicMemory ?? GameSettings.getDynamicMemory()
        self.resolution = resolution ?? GameSettings.getResolution()
        self.processPriority = processPriority
        self.advanced = advanced
    }

    private static let dynamicMemoryDefaultPortion: UInt64 = 8
    private static let resolutionDefault: Resolution = .window(
        width: 854, height: 480
    )
    private static let resolutionDefaultPortion: UInt = 4

    private static func getDynamicMemory() -> UInt {
        return UInt(ProcessInfo.processInfo.physicalMemory / (1024 * 1024 * dynamicMemoryDefaultPortion))
    }

    private static func getResolution() -> Resolution {
        let screen = CGDisplayScreenSize(CGMainDisplayID())
        return .window(width: UInt(screen.width), height: UInt(screen.height))
    }

    enum CodingKeys: String, CodingKey {
        case _dynamicMemory = "dynamicMemory"
        case _resolution = "resolution"
        case _processPriority = "processPriority"
        case _advanced = "advanced"
    }
}
