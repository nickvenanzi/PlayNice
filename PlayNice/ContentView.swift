//
//  ContentView.swift
//  PlayNice
//
//  Created by Nick Venanzi on 7/23/24.
//

import SwiftUI

enum Tabs: Equatable, Hashable {
    case PROMPT_INPUT
    case VOTING
    case LEADERBOARD
    case PROFILE
}

struct ContentView: View {

    @EnvironmentObject var appEngine: AppEngine
    @Environment(\.scenePhase) var scenePhase
    
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            PromptView()
                .tabItem {
                    Text("Prompt")
                    Image(systemName: "person.text.rectangle")
                }
                .tag(0)
            
            VoteView()
                .tabItem {
                    Text("Vote")
                    Image(systemName: "figure.gymnastics")
                }
                .tag(1)
            
            RankingView()
                .tabItem {
                    Text("Ranking")
                    Image(systemName: "list.number")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Text("Profile")
                    Image(systemName: "person.text.rectangle")
                }
                .tag(3)

            DeveloperView()
                .tabItem {
                    Text("Developer")
                    Image(systemName: "hammer")
                }
                .tag(4)
        }
        .tint(.gray)
        .onAppear(perform: {
            UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.4)
            appEngine.getUserDocument{}
        })
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                appEngine.timer?.cancel()
                appEngine.storeInCache()
            } else if newPhase == .active {
                appEngine.initializeTimer()
                appEngine.retrieveFromCache()
            }
        }
        .onChange(of: appEngine.prompt.submitted) { _, isSubmitted in
            print("Submitted state changed: \(isSubmitted)")
            if isSubmitted {
                selectedIndex = 1 // VoteView
            } else {
                selectedIndex = 0 // PromptView
            }
        }
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)  // Dismiss the keyboard
    }
}
