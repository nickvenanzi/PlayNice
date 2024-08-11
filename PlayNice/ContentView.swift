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

    @EnvironmentObject var timeEngine: TimeEngine
    @EnvironmentObject var userEngine: UserEngine
    @EnvironmentObject var promptEngine: PromptEngine
    
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            PromptView()
                .tabItem {
                    Text("Prompt")
                    Image(systemName: "person.text.rectangle")
                }
            
            VoteView()
                .tabItem {
                    Text("Vote")
                    Image(systemName: "figure.gymnastics")
                }
            
            RankingView()
                .tabItem {
                    Text("Ranking")
                    Image(systemName: "list.number")
                }
            
            ProfileView(isSelf: true)
                .tabItem {
                    Text("Profile")
                    Image(systemName: "person.text.rectangle")
                }
        }
        .tint(.gray)
        .onAppear(perform: {
            UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.4)
            userEngine.getUserDocument()
        })
        .onReceive(timeEngine.$today, perform: { newToday in
            promptEngine.retrievePrompt()
            userEngine.getUserDocument()
            userEngine.updateRankingsAndFollowing()
            print("Today changed")
            /*
             TO-DO
             3. Update User profile
             */
        })
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)  // Dismiss the keyboard
    }
}
