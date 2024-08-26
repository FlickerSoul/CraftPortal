//
//  LaunchManager.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/26/24.
//

class LaunchManager {
    weak var appState: AppState?

    func setAppState(_ appState: AppState) {
        self.appState = appState
    }

    func launch(profile: GameProfile? = nil) {
        let profile = profile ?? appState?.currentGameProfile

        // TODO: logging lauching failed
        guard let profile else { return }
    }
}
