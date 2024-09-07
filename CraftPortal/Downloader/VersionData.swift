//
//  VersionData.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/7/24.
//

struct LatestVersion {
    let release: String
    let snapshot: String
}

struct VersionInfo {
    let id: String
    let type: String
    let url: String
    let time: String
    let releaseTime: String
}

struct VersionManifest {
    let latest: LatestVersion
    let versions: [VersionInfo]
}
