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

    init(currentUserProfile: UserProfile? = nil) {
        self.currentUserProfile = currentUserProfile
    }

    func validateState(container: ModelContainer) {
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
