import Path

//
//  JVMSettingsView.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import SwiftUI

struct JVMChooser: View {
    @State private var showingPopover = false

    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var globalSettings: GlobalSettings

    var selectedJVM: SelectedJVM {
        globalSettings.selectedJVM
    }

    var body: some View {
        HStack {
            Image(systemName: "apple.terminal.on.rectangle")

            VStack(alignment: .leading) {
                Text("Java \(selectedJVM.formattedVersion)")
                    .font(.headline)
                Text(selectedJVM.formattedPath)
                    .font(.footnote)
            }
        }
        .onTapGesture {
            showingPopover.toggle()
        }
        .hoverCursor()
        .popover(isPresented: $showingPopover) {
            VStack(alignment: .center) {
                Picker("Available JVMs", selection: $globalSettings.selectedJVM) {
                    Text("Automatic").tag(SelectedJVM.automatic)

                    ForEach(
                        appState.jvmManager.sequentialVersions
                    ) { jvm in
                        VStack(alignment: .leading) {
                            Text(jvm.version)
                                .font(.headline)
                            Text(jvm.path)
                                .font(.subheadline)
                        }
                        .tag(SelectedJVM.manual(jvm))
                    }
                }
                .pickerStyle(.radioGroup)
            }
            .padding()
        }
    }
}

struct JVMPathOptionSheet: View {
    let jvmPathURL: URL

    @State private var isLoading: Bool = false
    @State private var selected: JVMInformation? = nil
    @State private var useAsCurrentJVM: Bool = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var globalSettings: GlobalSettings

    var body: some View {
        VStack(spacing: 16) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                VStack {
                    if let selected {
                        Text("Java version: \(selected.version)")
                            .font(.headline)
                        Text(selected.path)
                            .font(.subheadline)

                        Toggle("Use as current JVM", isOn: $useAsCurrentJVM)
                            .toggleStyle(.checkbox)

                    } else {
                        Text("There is an error loading java versions")
                    }
                }
            }

            HStack {
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Back")
                }

                Button {
                    if let selected {
                        appState.jvmManager.add(version: selected)

                        if useAsCurrentJVM {
                            globalSettings.selectedJVM = .manual(selected)
                        }
                    }

                    dismiss()
                } label: {
                    Text("Ok")
                }.disabled(selected == nil)
            }
        }
        .padding()
        .onAppear(perform: load)
    }

    func load() {
        isLoading = true
        DispatchQueue.global().async {
            self.selected = JVMInformation.from(url: jvmPathURL)
            self.isLoading = false
        }
    }
}

struct AddJVMPath: View {
    @State private var showingSheet = false
    @State private var selectedPath: URL? = nil

    var body: some View {
        Button {
            choosePath()
        } label: {
            Image(systemName: "plus.app")
        }
        .help("Add a JVM path to be used to launch the game.")
        .sheet(
            isPresented: $showingSheet,
            onDismiss: {
                selectedPath = nil
            }
        ) {
            JVMPathOptionSheet(jvmPathURL: selectedPath!)
        }.onChange(of: selectedPath) { _, newValue in
            if newValue != nil {
                showingSheet = true
            }
        }
    }

    func choosePath() {
        selectedPath = chooseFile(message: "Choose a JVM path")
    }
}

struct DiscoverJVMButton: View {
    var body: some View {
        Button {
            // TODO: run discover JVM
        } label: {
            Image(systemName: "magnifyingglass")
        }
        .help("Discover JVM paths that can be used to launch the game.")
    }
}

struct JVMSettingsView: View {
    var body: some View {
        HStack {
            JVMChooser()
            Spacer()
            DiscoverJVMButton()
            AddJVMPath()
        }
        .padding()
    }
}
