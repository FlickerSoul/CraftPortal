//
//  ResolutionInput.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import SwiftUI

struct ResolutionInput: View {
    let fullScreenBinding: Binding<Bool>
    let widthBinding: Binding<String>
    let heightBinding: Binding<String>

    var body: some View {
        HStack {
            Text("Resolution")
            Spacer()

            HStack {
                TextField("Width", text: widthBinding)
                    .frame(width: 64)
                    .textFieldStyle(.roundedBorder)
                Text("x")
                TextField("Height", text: heightBinding)
                    .frame(width: 64)
                    .textFieldStyle(.roundedBorder)
            }

            Toggle("Fullscreen", isOn: fullScreenBinding)
                .toggleStyle(.checkbox)
        }
        .padding()
    }
}
