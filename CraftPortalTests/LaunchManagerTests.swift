//
//  LaunchManagerTests.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/27/24.
//
import Foundation
import Path
import Testing

@testable import CraftPortal

@Suite
struct ClassPathTests {
    private static let CP_MAPPING = [
        (
            "1.21",
            "Assets/ProfiledVanillaGame/meta/versions/1.21",
            """
                /FakeDir/ca/weblite/java-objc-bridge/1.1/java-objc-bridge-1.1.jar:/FakeDir/com/github/oshi/oshi-core/6.4.10/oshi-core-6.4.10.jar:/FakeDir/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar:/FakeDir/com/google/guava/failureaccess/1.0.1/failureaccess-1.0.1.jar:/FakeDir/com/google/guava/guava/32.1.2-jre/guava-32.1.2-jre.jar:/FakeDir/com/ibm/icu/icu4j/73.2/icu4j-73.2.jar:/FakeDir/com/mojang/authlib/6.0.54/authlib-6.0.54.jar:/FakeDir/com/mojang/blocklist/1.0.10/blocklist-1.0.10.jar:/FakeDir/com/mojang/brigadier/1.2.9/brigadier-1.2.9.jar:/FakeDir/com/mojang/datafixerupper/8.0.16/datafixerupper-8.0.16.jar:/FakeDir/com/mojang/logging/1.2.7/logging-1.2.7.jar:/FakeDir/com/mojang/patchy/2.2.10/patchy-2.2.10.jar:/FakeDir/com/mojang/text2speech/1.17.9/text2speech-1.17.9.jar:/FakeDir/commons-codec/commons-codec/1.16.0/commons-codec-1.16.0.jar:/FakeDir/commons-io/commons-io/2.15.1/commons-io-2.15.1.jar:/FakeDir/commons-logging/commons-logging/1.2/commons-logging-1.2.jar:/FakeDir/io/netty/netty-buffer/4.1.97.Final/netty-buffer-4.1.97.Final.jar:/FakeDir/io/netty/netty-codec/4.1.97.Final/netty-codec-4.1.97.Final.jar:/FakeDir/io/netty/netty-common/4.1.97.Final/netty-common-4.1.97.Final.jar:/FakeDir/io/netty/netty-handler/4.1.97.Final/netty-handler-4.1.97.Final.jar:/FakeDir/io/netty/netty-resolver/4.1.97.Final/netty-resolver-4.1.97.Final.jar:/FakeDir/io/netty/netty-transport-classes-epoll/4.1.97.Final/netty-transport-classes-epoll-4.1.97.Final.jar:/FakeDir/io/netty/netty-transport-native-unix-common/4.1.97.Final/netty-transport-native-unix-common-4.1.97.Final.jar:/FakeDir/io/netty/netty-transport/4.1.97.Final/netty-transport-4.1.97.Final.jar:/FakeDir/it/unimi/dsi/fastutil/8.5.12/fastutil-8.5.12.jar:/FakeDir/net/java/dev/jna/jna-platform/5.14.0/jna-platform-5.14.0.jar:/FakeDir/net/java/dev/jna/jna/5.14.0/jna-5.14.0.jar:/FakeDir/net/sf/jopt-simple/jopt-simple/5.0.4/jopt-simple-5.0.4.jar:/FakeDir/org/apache/commons/commons-compress/1.26.0/commons-compress-1.26.0.jar:/FakeDir/org/apache/commons/commons-lang3/3.14.0/commons-lang3-3.14.0.jar:/FakeDir/org/apache/httpcomponents/httpclient/4.5.13/httpclient-4.5.13.jar:/FakeDir/org/apache/httpcomponents/httpcore/4.4.16/httpcore-4.4.16.jar:/FakeDir/org/apache/logging/log4j/log4j-api/2.22.1/log4j-api-2.22.1.jar:/FakeDir/org/apache/logging/log4j/log4j-core/2.22.1/log4j-core-2.22.1.jar:/FakeDir/org/apache/logging/log4j/log4j-slf4j2-impl/2.22.1/log4j-slf4j2-impl-2.22.1.jar:/FakeDir/org/jcraft/jorbis/0.0.17/jorbis-0.0.17.jar:/FakeDir/org/joml/joml/1.10.5/joml-1.10.5.jar:/FakeDir/org/lwjgl/lwjgl-freetype/3.3.3/lwjgl-freetype-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-freetype/3.3.3/lwjgl-freetype-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl-freetype/3.3.3/lwjgl-freetype-3.3.3-natives-macos-patch.jar:/FakeDir/org/lwjgl/lwjgl-glfw/3.3.3/lwjgl-glfw-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-glfw/3.3.3/lwjgl-glfw-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl-glfw/3.3.3/lwjgl-glfw-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl-jemalloc/3.3.3/lwjgl-jemalloc-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-jemalloc/3.3.3/lwjgl-jemalloc-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl-jemalloc/3.3.3/lwjgl-jemalloc-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl-openal/3.3.3/lwjgl-openal-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-openal/3.3.3/lwjgl-openal-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl-openal/3.3.3/lwjgl-openal-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl-opengl/3.3.3/lwjgl-opengl-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-opengl/3.3.3/lwjgl-opengl-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl-opengl/3.3.3/lwjgl-opengl-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl-stb/3.3.3/lwjgl-stb-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-stb/3.3.3/lwjgl-stb-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl-stb/3.3.3/lwjgl-stb-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl-tinyfd/3.3.3/lwjgl-tinyfd-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-tinyfd/3.3.3/lwjgl-tinyfd-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl-tinyfd/3.3.3/lwjgl-tinyfd-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl/3.3.3/lwjgl-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl/3.3.3/lwjgl-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl/3.3.3/lwjgl-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lz4/lz4-java/1.8.0/lz4-java-1.8.0.jar:/FakeDir/org/slf4j/slf4j-api/2.0.9/slf4j-api-2.0.9.jar:/MinecraftClient/1.21.jar
            """.trimmingCharacters(in: .whitespacesAndNewlines),
            "/MinecraftClient/1.21.jar"
        ),
        (
            "1.21.1-fabric-0.16.3",
            "Assets/ProfiledModdedGame/meta/versions/1.21.1-fabric-0.16.3",
            """
            /FakeDir/org/ow2/asm/asm/9.6/asm-9.6.jar:/FakeDir/org/ow2/asm/asm-analysis/9.6/asm-analysis-9.6.jar:/FakeDir/org/ow2/asm/asm-commons/9.6/asm-commons-9.6.jar:/FakeDir/org/ow2/asm/asm-tree/9.6/asm-tree-9.6.jar:/FakeDir/org/ow2/asm/asm-util/9.6/asm-util-9.6.jar:/FakeDir/net/fabricmc/sponge-mixin/0.15.2+mixin.0.8.7/sponge-mixin-0.15.2+mixin.0.8.7.jar:/FakeDir/net/fabricmc/intermediary/1.21.1/intermediary-1.21.1.jar:/FakeDir/net/fabricmc/fabric-loader/0.16.3/fabric-loader-0.16.3.jar:/FakeDir/ca/weblite/java-objc-bridge/1.1/java-objc-bridge-1.1.jar:/FakeDir/com/github/oshi/oshi-core/6.4.10/oshi-core-6.4.10.jar:/FakeDir/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar:/FakeDir/com/google/guava/failureaccess/1.0.1/failureaccess-1.0.1.jar:/FakeDir/com/google/guava/guava/32.1.2-jre/guava-32.1.2-jre.jar:/FakeDir/com/ibm/icu/icu4j/73.2/icu4j-73.2.jar:/FakeDir/com/mojang/authlib/6.0.54/authlib-6.0.54.jar:/FakeDir/com/mojang/blocklist/1.0.10/blocklist-1.0.10.jar:/FakeDir/com/mojang/brigadier/1.3.10/brigadier-1.3.10.jar:/FakeDir/com/mojang/datafixerupper/8.0.16/datafixerupper-8.0.16.jar:/FakeDir/com/mojang/logging/1.2.7/logging-1.2.7.jar:/FakeDir/com/mojang/patchy/2.2.10/patchy-2.2.10.jar:/FakeDir/com/mojang/text2speech/1.17.9/text2speech-1.17.9.jar:/FakeDir/commons-codec/commons-codec/1.16.0/commons-codec-1.16.0.jar:/FakeDir/commons-io/commons-io/2.15.1/commons-io-2.15.1.jar:/FakeDir/commons-logging/commons-logging/1.2/commons-logging-1.2.jar:/FakeDir/io/netty/netty-buffer/4.1.97.Final/netty-buffer-4.1.97.Final.jar:/FakeDir/io/netty/netty-codec/4.1.97.Final/netty-codec-4.1.97.Final.jar:/FakeDir/io/netty/netty-common/4.1.97.Final/netty-common-4.1.97.Final.jar:/FakeDir/io/netty/netty-handler/4.1.97.Final/netty-handler-4.1.97.Final.jar:/FakeDir/io/netty/netty-resolver/4.1.97.Final/netty-resolver-4.1.97.Final.jar:/FakeDir/io/netty/netty-transport-classes-epoll/4.1.97.Final/netty-transport-classes-epoll-4.1.97.Final.jar:/FakeDir/io/netty/netty-transport-native-unix-common/4.1.97.Final/netty-transport-native-unix-common-4.1.97.Final.jar:/FakeDir/io/netty/netty-transport/4.1.97.Final/netty-transport-4.1.97.Final.jar:/FakeDir/it/unimi/dsi/fastutil/8.5.12/fastutil-8.5.12.jar:/FakeDir/net/java/dev/jna/jna-platform/5.14.0/jna-platform-5.14.0.jar:/FakeDir/net/java/dev/jna/jna/5.14.0/jna-5.14.0.jar:/FakeDir/net/sf/jopt-simple/jopt-simple/5.0.4/jopt-simple-5.0.4.jar:/FakeDir/org/apache/commons/commons-compress/1.26.0/commons-compress-1.26.0.jar:/FakeDir/org/apache/commons/commons-lang3/3.14.0/commons-lang3-3.14.0.jar:/FakeDir/org/apache/httpcomponents/httpclient/4.5.13/httpclient-4.5.13.jar:/FakeDir/org/apache/httpcomponents/httpcore/4.4.16/httpcore-4.4.16.jar:/FakeDir/org/apache/logging/log4j/log4j-api/2.22.1/log4j-api-2.22.1.jar:/FakeDir/org/apache/logging/log4j/log4j-core/2.22.1/log4j-core-2.22.1.jar:/FakeDir/org/apache/logging/log4j/log4j-slf4j2-impl/2.22.1/log4j-slf4j2-impl-2.22.1.jar:/FakeDir/org/jcraft/jorbis/0.0.17/jorbis-0.0.17.jar:/FakeDir/org/joml/joml/1.10.5/joml-1.10.5.jar:/FakeDir/org/lwjgl/lwjgl-freetype/3.3.3/lwjgl-freetype-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-freetype/3.3.3/lwjgl-freetype-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl-freetype/3.3.3/lwjgl-freetype-3.3.3-natives-macos-patch.jar:/FakeDir/org/lwjgl/lwjgl-glfw/3.3.3/lwjgl-glfw-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-glfw/3.3.3/lwjgl-glfw-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl-glfw/3.3.3/lwjgl-glfw-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl-jemalloc/3.3.3/lwjgl-jemalloc-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-jemalloc/3.3.3/lwjgl-jemalloc-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl-jemalloc/3.3.3/lwjgl-jemalloc-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl-openal/3.3.3/lwjgl-openal-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-openal/3.3.3/lwjgl-openal-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl-openal/3.3.3/lwjgl-openal-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl-opengl/3.3.3/lwjgl-opengl-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-opengl/3.3.3/lwjgl-opengl-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl-opengl/3.3.3/lwjgl-opengl-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl-stb/3.3.3/lwjgl-stb-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-stb/3.3.3/lwjgl-stb-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl-stb/3.3.3/lwjgl-stb-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl-tinyfd/3.3.3/lwjgl-tinyfd-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl-tinyfd/3.3.3/lwjgl-tinyfd-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl-tinyfd/3.3.3/lwjgl-tinyfd-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lwjgl/lwjgl/3.3.3/lwjgl-3.3.3.jar:/FakeDir/org/lwjgl/lwjgl/3.3.3/lwjgl-3.3.3-natives-macos.jar:/FakeDir/org/lwjgl/lwjgl/3.3.3/lwjgl-3.3.3-natives-macos-arm64.jar:/FakeDir/org/lz4/lz4-java/1.8.0/lz4-java-1.8.0.jar:/FakeDir/org/slf4j/slf4j-api/2.0.9/slf4j-api-2.0.9.jar:/MinecraftClient/1.21.1.jar
            """.trimmingCharacters(in: .whitespacesAndNewlines),
            "/MinecraftClient/1.21.1.jar"
        ),
    ]

    @Test(
        "Test composing class paths",
        arguments: CP_MAPPING
    )
    func loadClassPathsTest(
        name: String, subdir: String, expectedCP: String, clientJar: String
    )
        throws
    {
        let launchManager = LaunchManager()

        let meta = try AssetLoader.shared.loadMinecraftMeta(
            name: name, from: subdir
        )

        let loadedCP = launchManager.composeClassPaths(
            from: meta, withLibBase: Path("/FakeDir/")!,
            withClientJar: Path(clientJar)!, features: [:]
        )

        #expect(loadedCP == expectedCP)
    }
}

@Suite
struct ArugmentsTests {
    private static let GAME_ARGUMENT_JSON = """
        [
          "--username",
          "${auth_player_name}",
          "--version",
          "${version_name}",
          "--gameDir",
          "${game_directory}",
          "--assetsDir",
          "${assets_root}",
          "--assetIndex",
          "${assets_index_name}",
          "--uuid",
          "${auth_uuid}",
          "--accessToken",
          "${auth_access_token}",
          "--clientId",
          "${clientid}",
          "--xuid",
          "${auth_xuid}",
          "--userType",
          "${user_type}",
          "--versionType",
          "${version_type}",
          {
            "rules": [
              {
                "action": "allow",
                "features": {
                  "is_demo_user": true
                }
              }
            ],
            "value": [
              "--demo"
            ]
          },
          {
            "rules": [
              {
                "action": "allow",
                "features": {
                  "has_custom_resolution": true
                }
              }
            ],
            "value": [
              "--width",
              "${resolution_width}",
              "--height",
              "${resolution_height}"
            ]
          },
          {
            "rules": [
              {
                "action": "allow",
                "features": {
                  "has_quick_plays_support": true
                }
              }
            ],
            "value": [
              "--quickPlayPath",
              "${quickPlayPath}"
            ]
          },
          {
            "rules": [
              {
                "action": "allow",
                "features": {
                  "is_quick_play_singleplayer": true
                }
              }
            ],
            "value": [
              "--quickPlaySingleplayer",
              "${quickPlaySingleplayer}"
            ]
          },
          {
            "rules": [
              {
                "action": "allow",
                "features": {
                  "is_quick_play_multiplayer": true
                }
              }
            ],
            "value": [
              "--quickPlayMultiplayer",
              "${quickPlayMultiplayer}"
            ]
          },
          {
            "rules": [
              {
                "action": "allow",
                "features": {
                  "is_quick_play_realms": true
                }
              }
            ],
            "value": [
              "--quickPlayRealms",
              "${quickPlayRealms}"
            ]
          }
        ]
    """.trimmingCharacters(in: .whitespacesAndNewlines)

    private static let GAME_ARG_MAPPING:
        [(
            LaunchArgValueCollection, LaunchFeatureCollection,
            LaunchArgPatchCollection, String
        )] = [
            (
                [
                    .authPlayerName: "player",
                    .versionName: "1.21",
                    .gameDirectory: "/FakeDir/",
                    .assetsRoot: "/AssetRoot/",
                    .assetsIndexName: "1",
                    .authUUID: "12345678901234567890123456789012",
                    .authAccessToken: "98765432109876543210987654321098",
                    .clientId: "client id",
                    .authXUID: "auth xuid",
                    .userType: "msa",
                    .versionType: "release",
                    .resolutionWidth: "1920",
                    .resolutionHeight: "1080",
                ],
                ["has_custom_resolution": true],
                [],
                "--username player --version 1.21 --gameDir /FakeDir/ --assetsDir /AssetRoot/ --assetIndex 1 --uuid 12345678901234567890123456789012 --accessToken 98765432109876543210987654321098 --clientId client id --xuid auth xuid --userType msa --versionType release --width 1920 --height 1080"
            ),
            (
                [
                    .authPlayerName: "player",
                    .versionName: "1.21",
                    .gameDirectory: "/FakeDir/",
                    .assetsRoot: "/AssetRoot/",
                    .assetsIndexName: "1",
                    .authUUID: "12345678901234567890123456789012",
                    .authAccessToken: "98765432109876543210987654321098",
                    .clientId: "client id",
                    .authXUID: "auth xuid",
                    .userType: "msa",
                    .versionType: "release",
                    .resolutionWidth: "1920",
                    .resolutionHeight: "1080",
                ],
                ["has_custom_resolution": false],
                [],
                "--username player --version 1.21 --gameDir /FakeDir/ --assetsDir /AssetRoot/ --assetIndex 1 --uuid 12345678901234567890123456789012 --accessToken 98765432109876543210987654321098 --clientId client id --xuid auth xuid --userType msa --versionType release"
            ),
            (
                [
                    .authPlayerName: "player",
                    .versionName: "1.21",
                    .gameDirectory: "/FakeDir/",
                    .assetsRoot: "/AssetRoot/",
                    .assetsIndexName: "1",
                    .authUUID: "12345678901234567890123456789012",
                    .authAccessToken: "98765432109876543210987654321098",
                    .clientId: "client id",
                    .authXUID: "auth xuid",
                    .userType: "msa",
                    .versionType: "release",
                    .resolutionWidth: "1920",
                    .resolutionHeight: "1080",
                ],
                [:],
                [],
                "--username player --version 1.21 --gameDir /FakeDir/ --assetsDir /AssetRoot/ --assetIndex 1 --uuid 12345678901234567890123456789012 --accessToken 98765432109876543210987654321098 --clientId client id --xuid auth xuid --userType msa --versionType release"
            ),
        ]

    @Test(
        "Test composing game arugments",
        arguments: GAME_ARG_MAPPING
    )
    func gameArgumentTest(
        argValues: LaunchArgValueCollection,
        features: LaunchFeatureCollection,
        patches: LaunchArgPatchCollection,
        expected: String
    ) throws {
        let launchManager = LaunchManager()
        let game = try JSONDecoder().decode(
            [MinecraftMetaArgumentElement].self,
            from: Self.GAME_ARGUMENT_JSON.data(using: .utf8)!
        )

        let actual = launchManager.composeArgs(
            from: game,
            argValues: argValues.plainArugments(),
            features: features,
            patches: patches
        )

        #expect(actual == expected)
    }

    private static let JVM_ARGUMENT_JSON = """
       [
          {
            "rules": [
              {
                "action": "allow",
                "os": {
                  "name": "osx"
                }
              }
            ],
            "value": [
              "-XstartOnFirstThread"
            ]
          },
          {
            "rules": [
              {
                "action": "allow",
                "os": {
                  "name": "windows"
                }
              }
            ],
            "value": [
              "-XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump"
            ]
          },
          {
            "rules": [
              {
                "action": "allow",
                "os": {
                  "name": "unknown",
                  "arch": "x86"
                }
              }
            ],
            "value": [
              "-Xss1M"
            ]
          },
          "-Djava.library.path=${natives_directory}",
          "-Djna.tmpdir=${natives_directory}",
          "-Dorg.lwjgl.system.SharedLibraryExtractPath=${natives_directory}",
          "-Dio.netty.native.workdir=${natives_directory}",
          "-Dminecraft.launcher.brand=${launcher_name}",
          "-Dminecraft.launcher.version=${launcher_version}",
          "-cp",
          "${classpath}"
        ]
    """

    private static let JVM_ARG_MAPPING:
        [(
            LaunchArgValueCollection,
            LaunchFeatureCollection,
            LaunchArgPatchCollection,
            String
        )] = [
            (
                [
                    .nativesDirectory: "/NativeDir/",
                    .launcherName: "CraftPortal",
                    .launcherVersion: "1.0.0",
                    .classpath: "cp",
                ],
                [:],
                [],
                "-XstartOnFirstThread -Djava.library.path=/NativeDir/ -Djna.tmpdir=/NativeDir/ -Dorg.lwjgl.system.SharedLibraryExtractPath=/NativeDir/ -Dio.netty.native.workdir=/NativeDir/ -Dminecraft.launcher.brand=CraftPortal -Dminecraft.launcher.version=1.0.0 -cp cp"
            ),
            (
                [
                    .nativesDirectory: "/NativeDir/",
                    .launcherName: "CraftPortal",
                    .launcherVersion: "1.0.0",
                    .classpath: "cp",
                ],
                [:],
                ["-extraArg"],
                "-XstartOnFirstThread -Djava.library.path=/NativeDir/ -Djna.tmpdir=/NativeDir/ -Dorg.lwjgl.system.SharedLibraryExtractPath=/NativeDir/ -Dio.netty.native.workdir=/NativeDir/ -Dminecraft.launcher.brand=CraftPortal -Dminecraft.launcher.version=1.0.0 -cp cp -extraArg"
            ),
        ]

    @Test("Test composing JVM arugments", arguments: JVM_ARG_MAPPING)
    func jvmArgumentTest(
        argValues: LaunchArgValueCollection,
        features: LaunchFeatureCollection,
        patches: LaunchArgPatchCollection,
        expected: String
    ) throws {
        let launchManager = LaunchManager()
        let jvm = try JSONDecoder().decode(
            [MinecraftMetaArgumentElement].self,
            from: Self.JVM_ARGUMENT_JSON.data(using: .utf8)!
        )

        let actual = launchManager.composeArgs(
            from: jvm,
            argValues: argValues.plainArugments(),
            features: features,
            patches: patches
        )

        #expect(actual == expected)
    }
}

@Suite
struct LaunchScriptTests {
    enum Expected {
        case Error(LauncherError)
        case Success(String)
    }

    static let assetFolderPath = try! AssetLoader.shared.loadAssetFolder(
        name: "Assets"
    ).path()

    static let mockLocalPlayerId: UUID = .init(
        uuidString: "00000000-0000-0000-0000-000000000000")!
    static let mockLocalPlayer: PlayerProfile = .init(
        id: mockLocalPlayerId, username: "fake_username",
        playerType: .Local
    )
    static let mockedVanillaGamePath = Path(assetFolderPath)! / "ProfiledVanillaGame"

    static let mockedVanillaGameDirectory: GameDirectory = .init(
        path: mockedVanillaGamePath,
        directoryType: .Profile
    )

    static let mockedVinallaGameProfile: GameProfile = .init(
        name: "Mocked Vanilla Game",
        gameVersion: .Release(major: 1, minor: 21), modLoader: nil,
        gameDirectory: mockedVanillaGameDirectory
    )

    static let mockedAppState = {
        let appState = AppState()
        appState.globalSettingsManager.setSettings(
            with:
            GlobalSettings(
                globalGameSettings: .init(
                    dynamicMemory: 4096,
                    resolution: .window(width: 1280, height: 720)
                )))

        return appState
    }()

    static let expectedVanillaGameShellScript = {
        let shellPath = mockedVanillaGamePath / "expected-shell.txt"
        return try! String(contentsOfFile: shellPath.string, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
    }()

    static let mockedJavaPath = "/Mocked/Java/Path/"

    @Test(
        "Test Launch Script Generation",
        arguments: [
            (
                mockLocalPlayer,
                mockedVinallaGameProfile,
                mockedAppState,
                Expected.Success(expectedVanillaGameShellScript)
            ),
        ]
    )
    func launchScriptTest(
        player: PlayerProfile, profile: GameProfile, appState: AppState,
        expected: Expected
    ) throws {
        let launchManager = LaunchManager()

        launchManager.setAppState(appState)

        switch expected {
        case let .Error(expectedError):
            #expect(throws: expectedError) {
                _ = try launchManager.composeLaunchScript(
                    player: player, profile: profile,
                    javaPath: LaunchScriptTests.mockedJavaPath
                )
            }
        case let .Success(expectedScript):
            let composed = try launchManager.composeLaunchScript(
                player: player, profile: profile,
                javaPath: LaunchScriptTests.mockedJavaPath
            )
            let simplified = composed.replacingOccurrences(
                of: LaunchScriptTests.assetFolderPath, with: ""
            )

            #expect(simplified == expectedScript)
        }
    }
}
