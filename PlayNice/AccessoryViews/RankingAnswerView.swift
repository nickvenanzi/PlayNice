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

struct RankingAnswerView_Previews: PreviewProvider {
    static var answer: Answer =
        Answer(answer: "Test Answer 2lsjdfhlaksdjhfalksdjhflajshdflkjahsdfs\n...more text...", prompt: "What is something you might find in President Joe Biden's search history?", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.81, votes: 2222222, date: AnswerDate(year: 2024, month: 7, day: 21), globalRank: 3)
    
    static var previews: some View {
        RankingAnswerView(answer)
    }
}
