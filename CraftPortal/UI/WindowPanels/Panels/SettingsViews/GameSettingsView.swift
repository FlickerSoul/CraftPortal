//
//  GameSettingsView.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/31/24.
//
import SwiftUI

struct GameSettingsView: View {
    @Binding var gameSettings: GameSettings

    var body: some View {
        let memoryBinding = Binding {
            Double(gameSettings.dynamicMemory)
        } set: { val in
            gameSettings.dynamicMemory = UInt(val)
        }

        let fullScreenBinding = Binding<Bool> {
            if case .fullscreen = gameSettings.resolution {
                return true
            }
            return false

        } set: { isFullscreen in
            switch gameSettings.resolution {
            case let .fullscreen(width, height), let .window(width, height):
                if isFullscreen {
                    gameSettings.resolution = .fullscreen(width: width, height: height)
                } else {
                    gameSettings.resolution = .window(width: width, height: height)
                }
            }
        }

        let widthBinding = Binding<String> {
            String(gameSettings.resolution.width)
        } set: { val in
            if let parsedVal = UInt(val) {
                let changeTo: Resolution
                switch gameSettings.resolution {
                case let .fullscreen(_, height):
                    changeTo = .fullscreen(width: parsedVal, height: height)

                case let .window(_, height):
                    changeTo = .window(width: parsedVal, height: height)
                }

                gameSettings.resolution = changeTo
            }
        }

        let heightBinding = Binding<String> {
            String(gameSettings.resolution.height)
        } set: { val in
            if let parsedVal = UInt(val) {
                let changeTo: Resolution
                switch gameSettings.resolution {
                case let .fullscreen(width, _):
                    changeTo = .fullscreen(width: width, height: parsedVal)

                case let .window(width, _):
                    changeTo = .window(width: width, height: parsedVal)
                }

                gameSettings.resolution = changeTo
            }
        }

        VStack {
            MemorySlider(memoryBinding: memoryBinding)
            Divider()
            ResolutionInput(fullScreenBinding: fullScreenBinding, widthBinding: widthBinding, heightBinding: heightBinding)
        }
    }
}
