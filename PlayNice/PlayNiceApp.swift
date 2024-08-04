//
//  PlayNiceApp.swift
//  PlayNice
//
//  Created by Nick Venanzi on 7/23/24.
//
import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct PlayNiceApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject var timeEngine: TimeEngine = TimeEngine.shared
    @StateObject var promptEngine: PromptEngine = PromptEngine.shared
    @StateObject var userEngine: UserEngine = UserEngine.shared
//    @StateObject var answerEngine: AnswerEngine = AnswerEngine.shared

    init() {
        Auth.auth().signInAnonymously { (authResult, error) in
            if let error = error {
                print("Error signing in anonymously: \(error.localizedDescription)")
                return
            }
            guard let user = authResult?.user else { return }
            UserEngine.shared.user.firebaseID = user.uid
            UserEngine.getUserDocument()
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timeEngine)
                .environmentObject(promptEngine)
                .environmentObject(userEngine)
//                .environmentObject(answerEngine)
        }
    }
}
