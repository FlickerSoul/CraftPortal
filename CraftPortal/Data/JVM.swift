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

    func getJVMInformation(to collection: inout Set<JVMInformation>) {
        switch self {
        case let .javaDir(path):
            if collection.filter({ info in
                info.path == path
            }).count != 0 {
                break
            }

            if let info = JVMInformation.from(path: path) {
                collection.insert(info)
            }

        case let .binDir(dir):
            return JavaSearchPath.javaDir(dir / "java").getJVMInformation(
                to: &collection)

        case let .javaCollectionDir(dir):
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
                    JavaSearchPath.binDir(binPath)
                        .getJVMInformation(to: &collection)
                } else if contentsPath.exists {
                    JavaSearchPath.binDir(
                        contentsPath / "Home/bin"
                    ).getJVMInformation(to: &collection)
                } else {
                    continue
                }
            }
        }
    }
}

struct JVMInformation: Codable, Equatable, Hashable, Identifiable {
    let path: Path
    let version: String

    var id: String { path.string }

    var majorVersion: Int? {
        let versionComponents = version.split(separator: ".")
        if versionComponents.first == "1", versionComponents.count > 1 {
            return Int(versionComponents[1])
        } else if let major = versionComponents.first {
            return Int(major)
        } else {
            return nil
        }
    }

    static func from(url: URL) -> JVMInformation? {
        if let path = Path(url: url) {
            return from(path: path)
        }

        return nil
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

            return .init(path: path, version: version)
        }

        return nil
    }
}

@Observable
class JVMManager {
    static let JVM_SERACH_PATHS: [JavaSearchPath] = [
        .javaCollectionDir(Path("/Library/Java/JavaVirtualMachines/")!),
        .javaDir(Path("/usr/bin/java")!),
        .javaCollectionDir(Path.home / ".jenv/versions/"),
        .javaCollectionDir(Path("/opt/homebrew/Cellar/openjdk/")!),
    ]

    static let JVM_CACHE_KEY: String = "JVM_CACHE_KEY"

    var versions: Set<JVMInformation>
    var sequentialVersions: [JVMInformation] {
        versions.sorted {
            $0.version > $1.version
        }
    }

    init() {
        versions = []
    }

    init(withExisting versions: any Sequence<JVMInformation>) {
        self.versions = Self.validate(versions: Set(versions))
    }

    func update(with versions: any Sequence<JVMInformation>) {
        self.versions.formUnion(versions)
        saveChanges()
    }

    func add(version: JVMInformation) {
        versions.insert(version)
        saveChanges()
    }

    func saveChanges() {
        UserDefaults.standard.set(try? JSONEncoder().encode(versions), forKey: JVMManager.JVM_CACHE_KEY)
    }

    static func validate(versions: Set<JVMInformation>) -> Set<JVMInformation> {
        return versions.filter { version in
            if version.path.exists {
                return true
            } else {
                return false
            }
        }
    }

    static func load() -> Set<JVMInformation> {
        if let data = UserDefaults.standard.data(forKey: JVMManager.JVM_CACHE_KEY), let decoded = try? JSONDecoder().decode(Set<JVMInformation>.self, from: data) {
            return validate(versions: decoded)
        }

        return Self.discover()
    }

    static func discover() -> Set<JVMInformation> {
        return JVMManager.JVM_SERACH_PATHS.reduce(
            into: Set<JVMInformation>()
        ) { partialResult, searchPath in
            searchPath.getJVMInformation(to: &partialResult)
        }
    }
}
