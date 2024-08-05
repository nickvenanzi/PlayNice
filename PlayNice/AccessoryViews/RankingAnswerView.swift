import SwiftUI

struct RankingAnswerView: View {
    
    var answer: Answer
    
    init(_ answer: Answer) {
        self.answer = answer
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
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

struct PercentageBar: View {
    var percentage: Double // A value between 0 and 100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.green)
                    .frame(width: CGFloat(percentage) * geometry.size.width, height: 10)
            }
        }
        .frame(height: 10)
    }
}
