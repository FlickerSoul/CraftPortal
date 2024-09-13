//
//  MSAccountAdder.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/10/24.
//
import SwiftUI

private enum AccountAddingSteps {
    case deviceCode
    case tokens

    var nextStep: Self? {
        switch self {
        case .deviceCode: return .tokens
        case .tokens: return nil
        }
    }
}

struct MSAccountAdderView: View {
    @State private var accountAddingSteps: AccountAddingSteps? = .deviceCode
    @State private var oAuthInfo: OAuthTokenInfo? = nil
    @Environment(\.dismiss) private var dismiss

    let loginManager: LoginManager = .init()

    var body: some View {
        currentStep
    }

    @ViewBuilder
    var currentStep: some View {
        switch accountAddingSteps {
        case .deviceCode:
            deviceCodeStep
        case .tokens:
            tokenStep
        case _:
            errorMessage
        }
    }

    @ViewBuilder
    var deviceCodeStep: some View {
        OAuthDeviceCodeView(loginManager: loginManager) { response in
            oAuthInfo = response
            GLOBAL_LOGGER.info("Received OAuth Token")
            nextStep()
        }
    }

    @ViewBuilder
    var tokenStep: some View {
        if let oAuthInfo {
            OAuthTokenLoadingView(
                loginManager: loginManager, oAuthInfo: oAuthInfo
            ) {
                nextStep()
            }
        } else {
            errorMessage
        }
    }

    @ViewBuilder
    var errorMessage: some View {
        Text("Internal State Error. Please contact the developer.")
    }

    func nextStep() {
        GLOBAL_LOGGER.debug("Moving to from step \(accountAddingSteps!)")

        if let accountAddingSteps, let nextStep = accountAddingSteps.nextStep {
            GLOBAL_LOGGER.debug("Moving to next step \(nextStep)")
            self.accountAddingSteps = nextStep
        } else {
            GLOBAL_LOGGER.debug("Finished adding account")
            dismiss()
        }
    }
}

#Preview("MS Account Adder") {
    Group {
        MSAccountAdderView()
    }.padding()
}
