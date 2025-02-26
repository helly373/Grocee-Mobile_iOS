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
            // Remove the outer NavigationStack here
            if isLoggedIn {
                MainTabView()   // <-- Each tab has its own NavigationStack
            } else {
                // If you want the LandingView to have a nav bar, you can wrap only it in a NavigationStack
                NavigationStack {
                    LandingView()
                }
            }
        }
    }
}
