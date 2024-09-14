//
//  LoginManager.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/10/24.
//
import Foundation

struct AccountInfo {
    let minecraftCredential: MinecraftAuthResponse
    let minecraftUser: MinecraftUserSuccessResponse
}

class LoginManager {
    let authenticator: Authenticator

    init(session: URLSession = .shared) {
        authenticator = Authenticator(session: session)
    }

    func getDeviceCode() async throws -> DeviceCodeResponse {
        return try await authenticator.getDeviceCode()
    }

    func verifyDeviceCode(with deviceCode: String) async throws
        -> OAuthTokenResponse
    {
        return try await authenticator.getOAuthToken(
            deviceCode: deviceCode)
    }

    func refresh(with refreshToken: String, for uuid: UUID) async throws -> (EssentialCredentials, Date) {
        let response = try await authenticator.refreshOAuthToken(refreshToken: refreshToken)

        if case let .success(succ) = response {
            let accountInfo = try await login(withOAuthToken: succ)

            let credential: EssentialCredentials = .init(oAuthAccessToken: succ.accessToken, oAuthRefreshToken: succ.refreshToken, minecraftToken: accountInfo.minecraftCredential.accessToken)

            try KeychainManager.saveFull(account: uuid, credential: credential)

            return (credential, Date.now + succ.expiresIn)
        } else {
            throw LoginError.failToRefreshLoginToken
        }
    }

    func login(withOAuthToken: OAuthTokenInfo) async throws -> AccountInfo {
        let xbl = try await authenticator.getXboxLiveToken(
            from: withOAuthToken.accessToken)
        let xsts = try await authenticator.getXstsToken(from: xbl.token)
        let minecraftAuth = try await authenticator.getMinecraftToken(
            from: xsts.token, uhs: xsts.uhs
        )

        let product = try await authenticator.getMinecraftProduct(from: minecraftAuth.accessToken)
        if product.items.isEmpty {
            throw LoginError.noMinecraftProduct(response: product)
        }

        let user = try await authenticator.getMinecraftUser(
            from: minecraftAuth.accessToken)

        switch user {
        case let .success(user):

            return .init(
                minecraftCredential: minecraftAuth, minecraftUser: user
            )
        case let .failure(failure):

            throw LoginError.noMinecraft(response: failure)
        }
    }
}
