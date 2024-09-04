//
//  SelectorIndicator.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/4/24.
//

import SwiftUI

struct SelectorIndicator: View {
    let selected: Bool

    var body: some View {
        HStack {
            Image(systemName:
                selected ? "checkmark" : "circle"
            )
            .frame(width: 16, height: 16)
            .contentTransition(.symbolEffect(.replace))

            Divider()
        }
        .hoverCursor()
    }
}
