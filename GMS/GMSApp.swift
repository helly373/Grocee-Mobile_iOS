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
            NavigationStack {  // ✅ Wrap inside NavigationStack
                if isLoggedIn {
                    HomePageView()
                } else {
                    LandingView()
                }
            }
        }
    }
}

