//
//  UUID+.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/27/24.
//
import Foundation

extension UUID {
    var flatUUIDString: String {
        uuidString.replacingOccurrences(of: "-", with: "")
    }
}

extension UUID {
    init?(flatUUIDString: String) {
        guard flatUUIDString.count == 32 else {
            return nil
        }

        let part1 = flatUUIDString.prefix(8)
        let part2 = flatUUIDString.dropFirst(8).prefix(4)
        let part3 = flatUUIDString.dropFirst(12).prefix(4)
        let part4 = flatUUIDString.dropFirst(16).prefix(4)
        let part5 = flatUUIDString.dropFirst(20)

        let formattedUUIDString = "\(part1)-\(part2)-\(part3)-\(part4)-\(part5)"

        self.init(uuidString: String(formattedUUIDString))
    }
}
