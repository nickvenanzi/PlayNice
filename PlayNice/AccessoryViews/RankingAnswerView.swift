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
                        .roundedTitleFont() // Applies the custom font modifier
                    Text(answer.author)
                        .roundedTitleFont() // Applies the custom font modifier
                }
            }
            AnswerPercentageBar(answer)
        }
    }
}
