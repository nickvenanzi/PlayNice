import SwiftUI

struct RankingAnswerView: View {
    
    var answer: Answer
    
    init(_ answer: Answer) {
        self.answer = answer
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                RankView(answer.globalRank ?? -1)
                    .frame(alignment: .leading)
                VStack(alignment: .leading) {
                    Text(answer.answer)
                        .font(.body)
                    Text(answer.author)
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            
            AnswerPercentageBar(answer)
        }
    }
}
