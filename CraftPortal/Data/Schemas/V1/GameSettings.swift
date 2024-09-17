//
//  GameSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/27/24.
//
import CoreGraphics
import Foundation
import SwiftData

enum Resolution: Codable {
    case fullscreen(width: UInt, height: UInt)
    case window(width: UInt, height: UInt)

    func toSizeStrings() -> (width: String, height: String) {
        switch self {
        case let .fullscreen(width: width, height: height), let .window(width: width, height: height):
            return (String(width), String(height))
        }
    }

    var width: UInt {
        switch self {
        case let .fullscreen(width: width, height: _), let .window(width: width, height: _):
            return width
        }
    }

    var height: UInt {
        switch self {
        case let .fullscreen(width: _, height: height), let .window(width: _, height: height):
            return height
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

extension CraftPortalSchemaV1 {
    @Model
    class GameSettings: Codable, ObservableObject {
        var dynamicMemory: UInt
        var showLogs: Bool = true
        var resolution: Resolution
        var processPriority: ProcessPriority
        var advanced: AdvancedSettings

        init(
            dynamicMemory: UInt? = nil,
            showLogs: Bool = true,
            resolution: Resolution? = nil,
            processPriority: ProcessPriority = .normal,
            advanced: AdvancedSettings = .init()
        ) {
            self.dynamicMemory = dynamicMemory ?? GameSettings.getDynamicMemory()
            self.showLogs = showLogs
            self.resolution = resolution ?? GameSettings.getResolution()
            self.processPriority = processPriority
            self.advanced = advanced
        }

        private static let dynamicMemoryDefaultPortion: UInt64 = 8
        private static let resolutionDefault: Resolution = .window(
            width: 854, height: 480
        )
        private static let resolutionDefaultPortion: UInt = 4
        static let physicalMemeoryCap: UInt64 =
            ProcessInfo.processInfo.physicalMemory / (1024 * 1024)

        private static func getDynamicMemory() -> UInt {
            return UInt(physicalMemeoryCap / dynamicMemoryDefaultPortion)
        }

        private static func getResolution() -> Resolution {
            let screen = CGDisplayScreenSize(CGMainDisplayID())
            return .window(width: UInt(screen.width), height: UInt(screen.height))
        }

        enum CodingKeys: String, CodingKey {
            case _dynamicMemory = "dynamicMemory"
            case _showLogs = "showLogs"
            case _resolution = "resolution"
            case _processPriority = "processPriority"
            case _advanced = "advanced"
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            dynamicMemory = try container.decode(UInt.self, forKey: ._dynamicMemory)
            showLogs = try container.decode(Bool.self, forKey: ._showLogs)
            resolution = try container.decode(Resolution.self, forKey: ._resolution)
            processPriority = try container.decode(ProcessPriority.self, forKey: ._processPriority)
            advanced = try container.decode(AdvancedSettings.self, forKey: ._advanced)
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(dynamicMemory, forKey: ._dynamicMemory)
            try container.encode(showLogs, forKey: ._showLogs)
            try container.encode(resolution, forKey: ._resolution)
            try container.encode(processPriority, forKey: ._processPriority)
            try container.encode(advanced, forKey: ._advanced)
        }
    }
}
