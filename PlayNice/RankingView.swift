import SwiftUI

struct RankingView: View {

    @EnvironmentObject var userEngine: UserEngine
    
    var rankings: [Answer] {
        return userEngine.rankings.sorted {
            ($0.globalRank ?? Int.max) < ($1.globalRank ?? Int.max)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(userEngine.rankings.first?.prompt ?? "")
                .font(.title)
                .padding()

            List(rankings) { answer in
                RankingAnswerView(answer)
            }
        }
    }
}
