//
//  GMSApp.swift
//  GMS
//
//  Created by Helly Prakashkumar Chauhan on 2025-02-14.
//
import SwiftUI

@main
struct GMSApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isLoggedIn {
                    HomePageView()
                } else {
                    LandingView()  // This is your landing screen
                }
            }
            .id(isLoggedIn) // Forces a rebuild of the NavigationStack when isLoggedIn changes.

        }
    }
}
