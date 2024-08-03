import SwiftUI

struct AnswerPercentageBar: View {
    let answer: Answer
    var includeVotes: Bool = true
    let barColor: Color
    @State private var animationProgress: Float

    init(_ answer: Answer) {
        self.answer = answer
        self.animationProgress = 1.0
        self.barColor = .green
    }
    
    init(_ answer: Answer, includeVotes: Bool, progress: Float, color: Color) {
        self.answer = answer
        self.includeVotes = includeVotes
        self.animationProgress = progress
        self.barColor = color
    }

    var body: some View {
        HStack {
            if includeVotes {
                Text("\(answer.votes) votes")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 70)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(barColor)
                        .frame(width: CGFloat(animationProgress * answer.winPercentage) * geometry.size.width)
                        .animation(.easeInOut(duration: 1.0), value: animationProgress * answer.winPercentage)
                    Spacer()
                }
            }
            .frame(height: 10)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .onAppear(perform: {
                withAnimation {
                    animationProgress = 1.0
                }
            })
            Text("\(Int(answer.winPercentage * 100))%")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct AnswerPercentageBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AnswerPercentageBar(Answer(answer: "Test Answer 1------------ ------------ blah blah blah is there a god in this dumb universe?", prompt: "Prompt 1 is the following question for ", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.7, votes: 2000, date: AnswerDate(year: 2024, month: 7, day: 22), globalRank: 111), includeVotes: false, progress: 0.0, color: .yellow)
            AnswerPercentageBar(Answer(answer: "Test Answer 2\n\n\n\n...more text...", prompt: "Prompt 2", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.81, votes: 22, date: AnswerDate(year: 2024, month: 7, day: 21), globalRank: 3))
            AnswerPercentageBar(Answer(answer: "Test Answer 1------------ ------------", prompt: "Prompt 1", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.7, votes: 24, date: AnswerDate(year: 2024, month: 7, day: 19), globalRank: 1))
        }
        .padding()
    }
}
