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
    
    @StateObject var timeEngine: TimeEngine = TimeEngine.shared
    @StateObject var promptEngine: PromptEngine = PromptEngine()
    @StateObject var userEngine: UserEngine = UserEngine()
//    @StateObject var answerEngine: AnswerEngine = AnswerEngine.shared

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timeEngine)
                .environmentObject(promptEngine)
                .environmentObject(userEngine)
//                .environmentObject(answerEngine)
                .onAppear {
                    Auth.auth().signInAnonymously { (authResult, error) in
                        if let _ = error {
                            return
                        }
                        guard let user = authResult?.user else { return }
                        userEngine.user.firebaseID = user.uid
                    }
                }
        }
    }
}
