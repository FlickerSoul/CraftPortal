//
//  OAuthDeviceCodeView.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/13/24.
//
import SwiftUI

struct OAuthDeviceCodeView: View {
    let loginManager: LoginManager
    let successCallback: (OAuthTokenInfo) -> Void

    @State private var failureMessage: String? = nil
    @State private var deviceCodeInfo: DeviceCodeResponse? = nil
    @State private var loadingNewCode = false
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if let deviceCodeInfo {
                VStack {
                    texts(deviceCodeInfo: deviceCodeInfo)
                    actions(deviceCodeInfo: deviceCodeInfo)
                }
            } else {
                loading
            }
        }
        .padding()
        .task {
            await refreshDeviceCode()
        }
    }

    @ViewBuilder
    @inlinable
    func actions(deviceCodeInfo: DeviceCodeResponse) -> some View {
        HStack {
            Button("Back", role: .cancel) {
                dismiss()
            }

            Button("I completed login") {
                handleLogin(deviceCodeInfo)
            }
        }
    }

    @ViewBuilder
    @inlinable
    func texts(deviceCodeInfo: DeviceCodeResponse) -> some View {
        Text("Login Through Microsoft With Device Code")
            .font(.title)

        Text(
            "Open [\(deviceCodeInfo.verificationUri)](\(deviceCodeInfo.verificationUri)) and enter the following code: "
        )
        .environment(
            \.openURL,
            .init(handler: { _ in
                NSWorkspace.shared.open(
                    URL(
                        string:
                        deviceCodeInfo.verificationUri)!)
                return .handled
            })
        )

        HStack {
            Text(deviceCodeInfo.userCode)
                .textSelection(.enabled)
                .font(.headline)
            Button {
                copyText(deviceCodeInfo.userCode)
            } label: {
                Image(systemName: "doc.on.doc")
            }.buttonStyle(.borderless)

            Button {
                Task {
                    await refreshDeviceCode()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .symbolEffect(.pulse, value: loadingNewCode)
            }
            .buttonStyle(.borderless)
            .disabled(loadingNewCode)
        }

        if let failureMessage {
            Text(failureMessage)
        }

        Text(
            "Once you completed login in the browser, click the button below to continue."
        )
    }

    @ViewBuilder
    var loading: some View {
        VStack {
            Text("Contacting Microsoft...")
                .font(.headline)

            ProgressView()
                .progressViewStyle(.circular)
        }
    }

    func dismissAndEmitError(title: String, description: String) {
        dismiss()
        appState.setError(title: title, description: description)
    }

    func refreshDeviceCode() async {
        withAnimation {
            loadingNewCode = true
        }

        do {
            deviceCodeInfo = try await loginManager.getDeviceCode()
        } catch {
            dismissAndEmitError(
                title: "Cannot load login",
                description:
                "Please check your network. Error: \(error.localizedDescription)"
            )
        }

        withAnimation {
            loadingNewCode = false
        }
    }

    func handleLogin(_ deviceCodeInfo: DeviceCodeResponse) {
        Task {
            do {
                let response = try await loginManager.verifyDeviceCode(
                    with: deviceCodeInfo.deviceCode)

                switch response {
                case let .success(info):
                    DispatchQueue.main.async {
                        successCallback(info)
                    }
                case let .failure(failure):
                    failureMessage = failure.error.detailedDescription
                }
            } catch {
                dismissAndEmitError(
                    title: "Cannot verify your response",
                    description: error.localizedDescription
                )
            }
        }
    }
}

#Preview("Device Code Loader") {
    Group {
        OAuthDeviceCodeView(loginManager: LoginManager()) { _ in
        }
    }.padding()
}
