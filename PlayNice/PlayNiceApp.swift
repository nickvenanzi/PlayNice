//
//  PlayNiceApp.swift
//  PlayNice
//
//  Created by Nick Venanzi on 7/23/24.
//
import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct PlayNiceApp: App {
    
    @StateObject var appEngine: AppEngine = AppEngine()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appEngine)
                .onAppear {
                    Auth.auth().signInAnonymously { (authResult, error) in
                        if let _ = error {
                            return
                        }
                        guard let user = authResult?.user else { return }
                        appEngine.user.firebaseID = user.uid
                    }
                }
        }
    }
}
