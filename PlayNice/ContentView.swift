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
    
    @StateObject var timeEngine = TimeEngine.shared
    
    @State private var selectedIndex: Int = 0
    @StateObject var user = User()
    @StateObject var prompt: Prompt = Prompt("What is your favorite programming language?", AnswerDate())
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            PromptView()
                .environmentObject(prompt)
                .tabItem {
                    Text("Prompt")
                    Image(systemName: "person.text.rectangle")
                }
            
            VoteView()
                .environmentObject(prompt)
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
                .environmentObject(user)
                .tabItem {
                    Text("Profile")
                    Image(systemName: "person.text.rectangle")
                }
        }
        .tint(.gray)
        .onAppear(perform: {
            UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.4)
        })
        .onReceive(timeEngine.$today, perform: { newToday in
            /*
             TO-DO
             1. Update prompt
             2. Update Rankings
             3. Update User profile
             */
        })
    }
}

#Preview {
    ContentView()
}
