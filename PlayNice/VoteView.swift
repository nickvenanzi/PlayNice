import SwiftUI

struct VoteView: View {
    
    @EnvironmentObject var appEngine: AppEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(appEngine.prompt.text)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.horizontal)
            
            if appEngine.currentAnswers.count == 0 {
                Text("No more answers available.  Come back later for more!")
            }

            ForEach(0..<appEngine.currentAnswers.count, id: \.self) { index in
                AnswerOptionView(
                    answer: appEngine.currentAnswers[index],
                    selectedAnswer: appEngine.selectedAnswer,
                    isSelected: appEngine.selectedAnswer == index
                )
                .onTapGesture {
                    // locally change %'s
                    for i in 0..<appEngine.currentAnswers.count {
                        var wins = appEngine.currentAnswers[i].winPercentage * Float(appEngine.currentAnswers[i].votes)
                        appEngine.currentAnswers[i].votes += 1
                        if i == index {
                            wins += 1.0
                        }
                        appEngine.currentAnswers[i].winPercentage = wins / Float(appEngine.currentAnswers[i].votes)
                    }
                    withAnimation(.easeInOut) {
                        appEngine.selectedAnswer = index
                        appEngine.castVotes()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        appEngine.getAnswerSet()
                    }
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .padding()
    }
}

struct AnswerOptionView: View {
    let answer: Answer
    var selectedAnswer: Int?
    var isSelected: Bool
    static let SELECTED_COLOR: Color = Color(red: 0, green: 1, blue: 0, opacity: 0.5)

    var body: some View {
        VStack {
            HStack {
                Text(answer.answer)
                    .font(.body)
                    .padding()
                    .background(isSelected  ? Self.SELECTED_COLOR : Color.gray.opacity(0.2))

                    .cornerRadius(10)
                Spacer()
            }
            .padding(.vertical, 5)

            if let _ = selectedAnswer {
                AnswerPercentageBar(answer, includeVotes: false, progress: 0, color: isSelected ? Self.SELECTED_COLOR: .gray)
                Spacer()
            }
        }
    }
}
