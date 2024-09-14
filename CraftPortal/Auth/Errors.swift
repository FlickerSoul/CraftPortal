//
//  Errors.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/10/24.
//

enum LoginError: Error {
    case failedToDecodeResponse(response: String?, message: String)
    case noMinecraft(response: MinecraftUserFailureResponse)
    case cannotParsePlayerUUID(String)
    case noMinecraftProduct(response: MinecraftProductResponse)
    case failToRefreshLoginToken
}
