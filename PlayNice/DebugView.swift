import SwiftUI

struct DebugView: View {
    
    @EnvironmentObject var appEngine: AppEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(appEngine.debugCounter)")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text("Today: \(appEngine.today.toString())")
                .font(.title3)
            
            Text("Number of answers in rankings: \(appEngine.rankings.count)")
            
            Text("Number of answers voted on: \(appEngine.votedOn.count)")
            
            Text("Number of answers in VoteView: \(appEngine.currentAnswers.count)")

            Text("Number of answers on deck: \(appEngine.answerQueue.count)")

            
        }
        .padding()
    }
}
