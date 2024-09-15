//
//  LaunchStatusMultiInstanceWarning.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/14/24.
//

import SwiftUI

struct LaunchStatusMultiInstanceWarning: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openWindow) private var openWindow

    let username: String

    var body: some View {
        VStack {
            Text("Warning")
                .font(.title)

            Text(
                "There are already games lauched under the user name '\(username)'. Continue lauching new game intances may cause trouble for existing game plays. We are not responsible for any loss caused by this"
            )
            .font(.headline)

            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }

                Button("Continue", role: .destructive) {
                    openWindow(id: "launch-logs")
                    dismiss()
                }
            }
        }
        .padding()
    }
}

#Preview("Multi Instance Warning") {
    @Previewable @State var override = false

    LaunchStatusMultiInstanceWarning(username: "user_name")
}
