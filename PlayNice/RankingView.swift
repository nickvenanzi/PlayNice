import SwiftUI

struct RankingView: View {
    
    @EnvironmentObject var appEngine: AppEngine
    
    var rankings: [Answer] {
        return appEngine.rankings.sorted {
            ($0.globalRank ?? Int.max) < ($1.globalRank ?? Int.max)
        }
    }
    var body: some View {
        ZStack {
            // Background image
            Image("ranking")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            // Overlay color with blur effect
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .blur(radius: 10)
            
            // Main content centered
            VStack {
                VStack(alignment: .leading) {
                    Text(appEngine.rankings.first?.prompt ?? "")
                        .roundedTitleFont()
                        .padding(.leading, 20)
                        .padding(.trailing, 20)

                    // Rankings list
                    List(rankings) { answer in
                        RankingAnswerView(answer)
                            .listRowBackground(Color.clear) // Makes the row background transparent
                    }
                    .frame(maxHeight: .infinity)
                    .listStyle(PlainListStyle())
                }
            }
            .padding(.top, 120)
        }
    }
}
