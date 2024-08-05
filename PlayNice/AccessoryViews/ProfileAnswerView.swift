import SwiftUI

struct ProfileAnswerView: View {
    
    var answer: Answer
    
    init(_ answer: Answer) {
        self.answer = answer
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                DateView(answer.date).frame(maxHeight: 50)

                Text(answer.prompt)
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(.leading, 5)
                if let rank = answer.globalRank {
                    Spacer()
                    RankView(rank)
                        .frame(alignment: .trailing)
                }
            }
            
            Text(answer.answer)
                .font(.body)
                .padding(.top, 10)
            
            AnswerPercentageBar(answer)
                .padding(.top, 10)
        }
    }
}
