//
//  MemorySlider.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//

import SwiftUI

struct MemorySlider: View {
    let memoryBinding: Binding<Double>

    var body: some View {
        let memoryTextBinding = Binding {
            String(format: "%.0f", memoryBinding.wrappedValue)
        } set: { val in
            if let parsedValue = Double(val) {
                memoryBinding.wrappedValue = parsedValue
            }
        }

        HStack {
            VStack {
                Text("Memory")

                Text("\(String(format: "%.2f", memoryBinding.wrappedValue / 1024)) GB")
            }
            Slider(
                value: memoryBinding,
                in: 0 ... Double(GameSettings.physicalMemeoryCap),
                step: 1024
            ) // TODO: make a custom one, this is too ugly

            TextField(
                "\(UInt(memoryBinding.wrappedValue)) MB",
                text: memoryTextBinding
            )
            .frame(width: 64)
            .textFieldStyle(.roundedBorder)

            Text("MB")
        }
        .padding()
    }
}
