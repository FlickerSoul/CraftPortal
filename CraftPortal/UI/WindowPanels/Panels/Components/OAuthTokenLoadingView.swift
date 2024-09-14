//
//  OAuthTokenLoadingView.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/13/24.
//
import SwiftUI

struct OAuthTokenLoadingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    @State private var userInfo: MinecraftUserSuccessResponse? = nil

    let loginManager: LoginManager
    let oAuthInfo: OAuthTokenInfo
    let successCallback: (PlayerProfile) -> Void

    var body: some View {
        VStack {
            Text("Loading Your Minecraft Account")
            ProgressView()
                .progressViewStyle(.circular)
        }
        .padding()
        .task {
            await addAccount()
        }
    }

    private func addAccount() async {
        let info: AccountInfo

        do {
            info = try await loginManager.login(withOAuthToken: oAuthInfo)
            GLOBAL_LOGGER.debug("Login info retrieved")
        } catch {
            appState.setError(
                title: "Login Failed", description: error.localizedDescription
            )
            return
        }

        let idString = info.minecraftUser.id
        guard let uuid = UUID(flatUUIDString: idString) else {
            appState.setError(
                title: "Cannnot Parse Player UUID",
                description:
                "Cannot parse player UUID (\(idString)) from response"
            )
            return
        }

        let player = PlayerProfile(
            id: uuid, username: info.minecraftUser.name,
            playerType: .MSA(expires: Date.now + info.minecraftCredential.expiresIn)
        )

        do {
            try KeychainManager.saveFull(
                account: uuid,
                credential: .init(
                    oAuthAccessToken: oAuthInfo.accessToken,
                    oAuthRefreshToken: oAuthInfo.refreshToken,
                    minecraftToken: info.minecraftCredential.accessToken
                )
            )

            GLOBAL_LOGGER.debug("Player credentials saved")

            modelContext.insert(player)

            GLOBAL_LOGGER.debug("Player account saved")
        } catch {
            appState.setError(
                title: "Cannot access keychain",
                description:
                "The application cannot access keychain to save the account. Please try again. Error: \(error)"
            )
        }

        successCallback(player)
    }
}
