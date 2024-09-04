import SwiftUI

struct RankingView: View {

    @EnvironmentObject var appEngine: AppEngine
    
    var rankings: [Answer] {
        return appEngine.rankings.sorted {
            ($0.globalRank ?? Int.max) < ($1.globalRank ?? Int.max)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(appEngine.rankings.first?.prompt ?? "")
                .font(.title)
                .padding()

            List(rankings) { answer in
                RankingAnswerView(answer)
            }
            .refreshable {
                appEngine.updateRankingsAndFollowing()
            }
        }
    }
}
