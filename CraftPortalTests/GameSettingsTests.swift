//
//  GameSettingsTests.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/30/24.
//
import Testing

@testable import CraftPortal

@Suite
struct ResolutionTests {
    @Test(
        "Test Resolution Formatting",
        arguments: [
            (Resolution.fullscreen(width: 400, height: 300), "400", "300"),
            (Resolution.window(width: 800, height: 600), "800", "600"),
        ]
    )
    func testResolutionFormatting(
        resolution: Resolution, width: String, height: String
    ) throws {
        let formatted = resolution.toSizeStrings()
        #expect(formatted == (width, height))
    }
}

@Suite
struct AdditionalJVMArgumentsTests {
    @Test
    func testDefaultAdditionalJVMArguments() throws {
        #expect(
            AdditionalJVMArguments.defaulted.arguments()
                == Set([
                    "-Dfile.encoding=UTF-8",
                    "-Dstdout.encoding=UTF-8",
                    "-Dstderr.encoding=UTF-8",
                    "-XX:+UnlockExperimentalVMOptions",
                    "-XX:+UseG1GC",
                    "-XX:G1NewSizePercent=20",
                    "-XX:G1ReservePercent=20",
                    "-XX:MaxGCPauseMillis=50",
                    "-Dfml.ignoreInvalidMinecraftCertificates=true",
                ])
        )
    }

    @Test
    func testCustomAdditionalJVMArguments() throws {
        #expect(
            AdditionalJVMArguments.custom(["-Xmx1G", "-XX:+UseG1GC"])
                .arguments() == Set(["-Xmx1G", "-XX:+UseG1GC"])
        )
    }

    @Test(
        "Test Advanced JVM Settings",
        arguments: [
            (
                JVMAdvancedSettings(),
                AdditionalJVMArguments.defaulted.arguments()
            ),
            (
                JVMAdvancedSettings(
                    additionalJVMArguments: .defaulted,
                    disableDefaultJVMArguments: true
                ),
                Set([])
            ),
            (
                JVMAdvancedSettings(
                    additionalJVMArguments: .custom(["-Dadditional"]),
                    disableDefaultJVMArguments: false
                ),
                AdditionalJVMArguments.defaulted.arguments().union(["-Dadditional"])
            ),
            (
                JVMAdvancedSettings(
                    additionalJVMArguments: .custom(["-Dadditional"]),
                    disableDefaultJVMArguments: true
                ),
                Set(["-Dadditional"])
            ),
        ]
    )
    func testJVMAdvancedSettings(
        settings: JVMAdvancedSettings, expected: Set<String>
    ) throws {
        let composed = settings.composeAdditionalJVMArguments()

        #expect(composed == expected)
    }
}
