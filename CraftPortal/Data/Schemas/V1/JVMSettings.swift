//
//  JVMSettings.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/1/24.
//
import SwiftData

extension CraftPortalSchemaV1 {
    @Model
    class JVMSettings: Codable {
        var selectedJVM: JVMInformation? = nil

        enum CodingKeys: String, CodingKey {
            case _selectedJVM = "selectedJVM"
        }

        init(selectedJVM: JVMInformation? = nil) {
            self.selectedJVM = selectedJVM
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            selectedJVM = try container.decode(JVMInformation.self, forKey: ._selectedJVM)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(selectedJVM, forKey: ._selectedJVM)
        }
    }
}
