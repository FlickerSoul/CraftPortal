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

    init?(flatUUIDString: String) {
        guard flatUUIDString.count == 32 else {
            return nil
        }

        let formattedUUIDString: String =
            flatUUIDString.prefix(8) + "-"
                + flatUUIDString.dropFirst(8).prefix(4) + "-"
                + flatUUIDString.dropFirst(12).prefix(4) + "-"
                + flatUUIDString.dropFirst(16).prefix(4) + "-"
                + flatUUIDString.dropFirst(20)

        self.init(uuidString: String(formattedUUIDString))
    }
}
