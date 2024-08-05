import SwiftUI

struct VoteView: View {
    @State private var selectedAnswer: Int? = nil
    @EnvironmentObject var promptEngine: PromptEngine
    
    var answers: [Answer] = [] // TO-DO

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(promptEngine.prompt.text)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.horizontal)

            ForEach(0..<answers.count, id: \.self) { index in
                AnswerOptionView(
                    answer: answers[index],
                    selectedAnswer: selectedAnswer,
                    isSelected: selectedAnswer == index
                )
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selectedAnswer = index
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
