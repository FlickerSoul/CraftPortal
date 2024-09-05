//
//  MicrosoftOAuth.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/4/24.
//

import Foundation

struct DevicdeCodeResponse: Decodable {
    let deviceCode: String
    let userCode: String
    let verificationUri: String
}

struct OAuthTokenInfo: Decodable {
    let tokenType: String
    let scope: String
    let expiresIn: Int
    let accessToken: String
    let refreshToken: String
}

enum OTokenFailureError: String, Decodable {
    case pending = "authorization_pending"
    case declined = "authorization_declined"
    case badDeviceCode = "bad_verification_code"
    case expiredCode = "expired_token"
}

struct OTokenFailure: Decodable {
    let error: OTokenFailureError
}

enum OAuthTokenResponse: Decodable {
    case success(OAuthTokenInfo)
    case failure(OTokenFailure)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let tokenInfo = try? container.decode(OAuthTokenInfo.self) {
            self = .success(tokenInfo)
            return
        }

        if let tokenFailure = try? container.decode(OTokenFailure.self) {
            self = .failure(tokenFailure)
            return
        }

        throw DecodingError.dataCorruptedError(
            in: container, debugDescription: "Cannot decode TokenResponse"
        )
    }
}

struct XboxLiveTokenClaims: Decodable {
    let xui: [[String: String]]
}

struct XboxLiveTokenResponse: Decodable {
    let issueInstant: String
    let notAfter: String
    let token: String
    let displayClaims: XboxLiveTokenClaims
}

struct XstsTokenResponse: Decodable {
    let issueInstant: String
    let notAfter: String
    let token: String
    let displayClaims: XboxLiveTokenClaims
}

struct MinecraftAuthResponse: Decodable {
    let username: String
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
}

struct MinecraftSkin: Decodable {
    let id: String
    let state: String
    let url: String
    let variant: String
    let alias: String
}

struct MinecraftUserResponse: Decodable {
    let id: String
    let name: String
    let skins: [MinecraftSkin]
    let capes: [String: String]
}

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

    func getDeviceCode() async throws -> DevicdeCodeResponse {
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
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(DevicdeCodeResponse.self, from: data)
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
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(OAuthTokenResponse.self, from: data)
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

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        return try decoder.decode(XboxLiveTokenResponse.self, from: data)
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

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        return try decoder.decode(XstsTokenResponse.self, from: data)
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

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(MinecraftAuthResponse.self, from: data)
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

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(MinecraftUserResponse.self, from: data)
    }
}
