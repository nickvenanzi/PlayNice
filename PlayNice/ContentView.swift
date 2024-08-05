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
        })
        .onReceive(timeEngine.$today, perform: { newToday in
            PromptEngine.retrievePrompt()
            UserEngine.getUserDocument()
            UserEngine.updateRankingsAndFollowing()
            
            /*
             TO-DO
             3. Update User profile
             */
        })
    }
}

#Preview {
    ContentView()
}
