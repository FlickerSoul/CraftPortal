//
//  Data.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/5/24.
//

struct DeviceCodeResponse: Decodable {
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

    var description: String {
        rawValue.split(separator: "_").map {
            String($0.first?.uppercased() ?? "") + $0[1...]
        }.joined(separator: " ")
    }

    var detailedDescription: String {
        switch self {
        case .pending:
            "You have not logged into your microsoft account. Please try again."
        case .declined:
            "You have declined logging in. Please refresh the device code and try again."
        case .badDeviceCode:
            "An internal error has occured. Please try again."
        case .expiredCode:
            "The device code has expired. Please refresh the device code and try again."
        }
    }
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

    var uhs: String {
        displayClaims.xui.first!["uhs"] ?? ""
    }
}

struct MinecraftAuthResponse: Decodable {
    let username: String
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
}

struct MinecraftProductItem: Decodable {
    let name: String
    let signature: String
}

struct MinecraftProductResponse: Decodable {
    let signature: String
    let keyId: String
    let items: [MinecraftProductItem]
}

enum MinecraftSkinState: String, Decodable {
    case inactive = "INACTIVE"
    case active = "ACTIVE"
}

struct MinecraftSkin: Decodable {
    let id: String
    let state: MinecraftSkinState
    let url: String
    let textureKey: String
    let variant: String
    let alias: String?
}

struct MinecraftCape: Decodable {
    let id: String
    let state: MinecraftSkinState
    let url: String
    let alias: String?
}

struct MinecraftUserSuccessResponse: Decodable {
    let id: String
    let name: String
    let skins: [MinecraftSkin]
    let capes: [MinecraftCape]
}

struct MinecraftUserFailureResponse: Decodable {
    let errorType: String
    let error: String
    let errorMessage: String
    let developerMessage: String
}

enum MinecraftUserResponse: Decodable {
    case success(MinecraftUserSuccessResponse)
    case failure(MinecraftUserFailureResponse)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let tokenInfo = try? container.decode(MinecraftUserSuccessResponse.self) {
            self = .success(tokenInfo)
            return
        }

        if let tokenFailure = try? container.decode(MinecraftUserFailureResponse.self) {
            self = .failure(tokenFailure)
            return
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Cannot decode MinecraftUserResponse"
        )
    }
}
