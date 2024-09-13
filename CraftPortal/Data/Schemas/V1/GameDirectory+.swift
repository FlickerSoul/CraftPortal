import Foundation

//
//  GameDirectory+.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import Path

extension GameDirectory {
    static func discoverMangledProfiles(in dir: GameDirectory) -> [GameProfile] {
        let dirPath = Path(dir.path)!

        guard dirPath.exists, dirPath.isDirectory else {
            return []
        }

        let versionsDir = dirPath / "versions"

        let versionPaths = [String: Path](
            uniqueKeysWithValues:
            versionsDir.ls().filter { path in
                // Ignore non-directories
                path.isDirectory
            }.map { path in
                (path.components.last!, path) // Guaranteed to have last in the component
            }
        )

        var results = [GameProfile]()

        let versionMetadata = [String: MinecraftMetadata](
            uniqueKeysWithValues: versionPaths.compactMap { version, path in
                let metaJsonPath = path / "\(version).json"

                // Ignore existing ones
                if dir.gameProfiles.first(where: { $0.name == version }) != nil {
                    return nil
                }

                if let data = try? Data(contentsOf: metaJsonPath.url),
                   let metadata = try? JSONDecoder().decode(
                       MinecraftMetadata.self, from: data
                   )
                {
                    return (
                        version,
                        metadata
                    )
                }

                return nil
            })

        for (version, metadata) in versionMetadata {
            var fullMeta: MinecraftMeta?

            switch metadata {
            case let .full(meta):
                fullMeta = meta
            case let .inherits(inheritsMeta):
                if case let .full(metaToBePatched) = versionMetadata[
                    inheritsMeta.inheritsFrom
                ] {
                    fullMeta = metaToBePatched.patch(with: inheritsMeta)
                }
            }

            if let fullMeta,
               let profile = GameProfile.from(
                   name: version, fullMeta: fullMeta, directory: dir
               )
            {
                results.append(profile)
            }
        }

        return results
    }

    static func discoverProfiledProfiles(in _: GameDirectory) -> [GameProfile] {
        // TODO: implement this
        return []
    }

    static func discoverProfiles(in dir: GameDirectory) -> [GameProfile] {
        switch dir.directoryType {
        case .mangled:
            return discoverMangledProfiles(in: dir)
        case .isolated:
            return discoverProfiledProfiles(in: dir)
        }
    }
}
