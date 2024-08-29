//
//  JVM.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/28/24.
//
import Foundation
import Path

enum JavaSearchPath {
    case javaCollectionDir(Path)
    case binDir(Path)
    case javaDir(Path)

    var path: Path? {
        switch self {
        case let .javaCollectionDir(dir), let .binDir(dir), let .javaDir(dir):
            return dir
        }
    }

    func getJVMInformation() -> Set<JVMInformation> {
        switch self {
        case let .javaDir(dir):
            if let info = JVMInformation.from(path: dir) {
                return [info]
            }
            return []
        case let .binDir(dir):
            return JavaSearchPath.javaDir(dir / "java").getJVMInformation()
        case let .javaCollectionDir(dir):
            var result = Set<JVMInformation>()

            for versionDir in dir.ls() {
                let realDir: Path?
                if versionDir.isSymlink {
                    realDir = try? versionDir.realpath()
                } else {
                    realDir = versionDir
                }

                guard let realDir = realDir, realDir.isDirectory else {
                    continue
                }

                let binPath = realDir / "bin"
                let contentsPath = realDir / "Contents"

                if binPath.exists {
                    result.formUnion(
                        JavaSearchPath.binDir(versionDir / "bin")
                            .getJVMInformation())
                } else if contentsPath.exists {
                    result.formUnion(
                        JavaSearchPath.binDir(
                            contentsPath / "Home/bin"
                        ).getJVMInformation())
                } else {
                    continue
                }
            }
            return result
        }
    }
}

struct JVMInformation: Codable, Equatable, Hashable {
    let path: String
    let version: String

    var majorVersion: Int? {
        guard let major = version.split(separator: ".").first else {
            return nil
        }
        return Int(major)
    }

    static func from(path: Path) -> JVMInformation? {
        let task = Process()

        task.executableURL = path.url
        task.arguments = ["-version"] // This output goes to stderr

        let pipe = Pipe()
        task.standardError = pipe

        do {
            try task.run()
        } catch {
            return nil
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()

        guard let output = String(data: data, encoding: .utf8) else {
            return nil
        }

        for line in output.split(separator: "\n") {
            let components = line.split(separator: " ")

            guard let versionIndex = components.firstIndex(of: "version")
            else {
                continue
            }

            let versionNumberIndex = versionIndex + 1
            let version = String(components[versionNumberIndex])

            return .init(path: path.string, version: version)
        }

        return nil
    }
}

struct JVMManager {
    static let JVM_SERACH_PATHS: [JavaSearchPath] = [
        .javaCollectionDir(Path("/Library/Java/JavaVirtualMachines/")!),
        .javaDir(Path("/usr/bin/java")!),
        //        .javaCollectionDir(Path.home / ".jenv/versions/"),  // Not usable because of sandboxing
        .javaCollectionDir(Path("/opt/homebrew/Cellar/openjdk/")!),
    ]

    var versions: Set<JVMInformation>

    init() {
        versions = []
    }

    init(withExisting versions: any Sequence<JVMInformation>) {
        self.versions = Set(versions)
        validate()
    }

    mutating func validate() {
        versions = versions.filter { version in
            if let javaPath = Path(version.path), javaPath.exists {
                return true
            } else {
                return false
            }
        }
    }

    mutating func discover() {
        for searchPath in JVMManager.JVM_SERACH_PATHS {
            versions.formUnion(searchPath.getJVMInformation())
        }
    }
}
