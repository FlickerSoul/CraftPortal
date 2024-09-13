//
//  MicrosoftOAuth.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/4/24.
//

import Foundation

extension JSONDecoder.KeyDecodingStrategy {
    static var convertFromPascalCase: JSONDecoder.KeyDecodingStrategy {
        return .custom { keys -> CodingKey in
            // keys array is never empty
            let key = keys.last!
            // Do not change the key for an array
            guard key.intValue == nil else {
                return key
            }

            let codingKeyType = type(of: key)
            let newStringValue = key.stringValue.firstCharLowercased()

            return codingKeyType.init(stringValue: newStringValue)!
        }
    }
}

private extension String {
    func firstCharLowercased() -> String {
        prefix(1).lowercased() + dropFirst()
    }
}

private func decode<T: Decodable>(from data: Data, strategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, errorMessage: String) throws -> T {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = strategy
    do {
        return try decoder.decode(T.self, from: data)
    } catch {
        throw LoginError.failedToDecodeResponse(response: String(data: data, encoding: .utf8), message: errorMessage)
    }
}

class Authenticator {
    static let oauthDeviceCode = URL(
        string:
        "https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode"
    )!
    static let oauth2Token = URL(
        string: "https://login.microsoftonline.com/consumers/oauth2/v2.0/token")!
    static let xboxLiveAuth = URL(
        string: "https://user.auth.xboxlive.com/user/authenticate")!
    static let xstsAuth = URL(
        string: "https://xsts.auth.xboxlive.com/xsts/authorize")!
    static let minecraftAuth = URL(
        string:
        "https://api.minecraftservices.com/authentication/login_with_xbox")!
    static let minecraftProfile = URL(
        string: "https://api.minecraftservices.com/minecraft/profile")!

    static let scope = "XboxLive.signin offline_access"
    static let clientID = "993bee92-f6cb-40b9-b0c6-f9768abbe636"

    static func encodeParameters(params: [String: String]) -> String {
        let queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        var components = URLComponents()
        components.queryItems = queryItems
        return components.percentEncodedQuery ?? ""
    }

    static func getXboxLiveAuthBody(from accessToken: String) -> Data? {
        """
        {
            "Properties": {
                "AuthMethod": "RPS",
                "SiteName": "user.auth.xboxlive.com",
                "RpsTicket": "d=\(accessToken)"
            },
            "RelyingParty": "http://auth.xboxlive.com",
            "TokenType": "JWT"
        }
        """.data(using: .utf8)
    }

    static func getXstsAuthbody(from xblToken: String) -> Data? {
        """
        {
            "Properties": {
                "SandboxId": "RETAIL",
                "UserTokens": [
                    "\(xblToken)"
                ]
            },
            "RelyingParty": "rp://api.minecraftservices.com/",
            "TokenType": "JWT"
        }
        """.data(using: .utf8)
    }

    static func getMinecraftAuthBody(withToken xstsToken: String, uhs: String)
        -> Data?
    {
        """
        {
            "identityToken": "XBL3.0 x=\(uhs);\(xstsToken)"
        }
        """.data(using: .utf8)
    }

    private var session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func getDeviceCode() async throws -> DeviceCodeResponse {
        var request = URLRequest(url: Authenticator.oauthDeviceCode)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]
        request.httpBody = Authenticator.encodeParameters(params: [
            "client_id": Authenticator.clientID,
            "scope": Authenticator.scope,
        ]).data(using: .utf8)

        let (data, _) = try await session.data(for: request)
        return try decode(from: data, strategy: .convertFromSnakeCase, errorMessage: "Cannot decode device code response. Pleaese contact the developer.")
    }

    func getOAuthToken(deviceCode: String) async throws
        -> OAuthTokenResponse
    {
        var request = URLRequest(url: Authenticator.oauth2Token)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]
        request.httpBody = Authenticator.encodeParameters(params: [
            "grant_type": "urn:ietf:params:oauth:grant-type:device_code",
            "client_id": Authenticator.clientID,
            "device_code": deviceCode,
        ]).data(using: .utf8)

        let (data, _) = try await session.data(for: request)
        return try decode(from: data, strategy: .convertFromSnakeCase, errorMessage: "Cannot decode OAuth token response. Pleaese contact the developer.")
    }

    func refreshOAuthToken(refreshToken: String) async throws -> OAuthTokenResponse {
        var request = URLRequest(url: Authenticator.oauth2Token)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]
        request.httpBody = Authenticator.encodeParameters(params: [
            "grant_type": "refresh_token",
            "client_id": Authenticator.clientID,
            "refresh_token": refreshToken,
            "scope": Authenticator.scope,
        ]).data(using: .utf8)

        let (data, _) = try await session.data(for: request)

        return try decode(from: data, strategy: .convertFromSnakeCase, errorMessage: "Cannot refresh OAuth token. Please try again. If this error persists, please contact the developer.")
    }

    func getXboxLiveToken(from accessToken: String) async throws
        -> XboxLiveTokenResponse
    {
        var request = URLRequest(url: Authenticator.xboxLiveAuth)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
        request.httpBody = Authenticator.getXboxLiveAuthBody(from: accessToken)

        let (data, _) = try await session.data(for: request)

        return try decode(from: data, strategy: .convertFromPascalCase, errorMessage: "Cannot decode Xbox Live token. Pleaase contact the developer.")
    }

    func getXstsToken(from xblToken: String) async throws
        -> XstsTokenResponse
    {
        var request = URLRequest(url: Authenticator.xstsAuth)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
        request.httpBody = Authenticator.getXstsAuthbody(from: xblToken)
        let (data, _) = try await session.data(for: request)

        return try decode(from: data, strategy: .convertFromPascalCase, errorMessage: "Cannot decode XSTS token. It is possible you have not registered your XBox Live account. Please contact the developer if you think this is an error.")
    }

    func getMinecraftToken(from xstsToken: String, uhs: String) async throws
        -> MinecraftAuthResponse
    {
        var request = URLRequest(url: Authenticator.minecraftAuth)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
        request.httpBody = Authenticator.getMinecraftAuthBody(
            withToken: xstsToken, uhs: uhs
        )

        let (data, _) = try await session.data(for: request)

        return try decode(from: data, strategy: .convertFromSnakeCase, errorMessage: "Cannot decode Minecraft token. Please contact the developer.")
    }

    func getMinecraftUser(from minecraftToken: String) async throws
        -> MinecraftUserResponse
    {
        var request = URLRequest(url: Authenticator.minecraftProfile)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(minecraftToken)",
        ]
        let (data, _) = try await session.data(for: request)

        return try decode(from: data, errorMessage: "Cannot decode Minecraft player details. Please contact the developer.")
    }
}
