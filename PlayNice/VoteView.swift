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

            ForEach(0..<appEngine.currentAnswers.count, id: \.self) { index in
                AnswerOptionView(
                    answer: appEngine.currentAnswers[index],
                    selectedAnswer: appEngine.selectedAnswer,
                    isSelected: appEngine.selectedAnswer == index
                )
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        appEngine.selectedAnswer = index
                        appEngine.castVotes()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        appEngine.getAnswerSet()
                    }
                }
                .padding(.horizontal)
            }
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
