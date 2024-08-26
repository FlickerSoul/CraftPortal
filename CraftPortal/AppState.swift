//
//  AppState.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//
import Foundation
import SwiftData

final class AppState: ObservableObject {
    @Published var currentUserProfile: UserProfile?
    @Published var currentGameDirectory: GameDirectory?

    init(
        currentUserProfile: UserProfile? = nil,
        currentGameDirectory: GameDirectory? = nil
    ) {
        self.currentUserProfile = currentUserProfile
        self.currentGameDirectory = currentGameDirectory
    }

    func validateState(container: ModelContainer) {
        validateUserProfile(container: container)
    }

    func validateUserProfile(container: ModelContainer) {
        let context = ModelContext(container)

        // validate usre still exists
        if currentUserProfile != nil {
            let fetchedProfiles = try? context.fetch(
                FetchDescriptor<UserProfile>(
                    predicate: #Predicate { userProfile in
                        if let currentUserProfile = currentUserProfile {
                            return currentUserProfile.id == userProfile.id
                        } else {
                            return false
                        }
                    }
                ))

            if fetchedProfiles == nil || fetchedProfiles!.isEmpty {
                currentUserProfile = nil
            }
        }
    }
}
