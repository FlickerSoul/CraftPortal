//
//  ShowLogsToggle.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/15/24.
//
import SwiftUI

struct ShowLogsToggle: View {
    let showLogs: Binding<Bool>

    var body: some View {
        HStack {
            Toggle("Show Logs", isOn: showLogs)
        }.padding()
    }
}
