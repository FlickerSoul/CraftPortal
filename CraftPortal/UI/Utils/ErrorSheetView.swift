//
//  ErrorSheetView.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/8/24.
//

import SwiftUI

struct ErrorSheetView: View {
    @Environment(\.dismiss) var dismiss
    let error: ErrorInfo

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            VStack(alignment: .center) {
                Text(error.title)
                    .font(.title)
                Text(error.description)
                    .font(.headline)
            }
            HStack {
                ForEach(error.callbacks, id: \.buttonName) { callback in
                    Button(callback.buttonName) {
                        callback.callback()
                        dismiss()
                    }
                }

                Button("Close") {
                    dismiss()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ErrorSheetView(
        error: ErrorInfo(
            title: "Error",
            description:
            "The exit code was not 0 but 127. Please check out logs for more information."
        ))
}
