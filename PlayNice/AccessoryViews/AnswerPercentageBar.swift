import SwiftUI

struct AnswerPercentageBar: View {
    let answer: Answer
    var includeVotes: Bool = true
    let barColor: Color
    var postfix: String = "votes"
    @State private var animationProgress: Float

    init(_ answer: Answer) {
        self.answer = answer
        self.animationProgress = 1.0
        self.barColor = .green
    }
    
    init(_ answer: Answer, _ postfix: String) {
        self.answer = answer
        self.animationProgress = 1.0
        self.barColor = .green
        self.postfix = postfix
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
                Text("\(answer.votes) \(postfix)")
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
