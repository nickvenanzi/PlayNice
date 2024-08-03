import SwiftUI

struct VoteView: View {
    @State private var selectedAnswer: Int? = nil
    @EnvironmentObject var prompt: Prompt
    let answers: [Answer]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(prompt.text)
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

struct VoteView_Previews: PreviewProvider {
    static var previews: some View {
        VoteView(
            answers: [
                Answer(answer: "Test Answer 1------------ ------------", prompt: "Prompt 1", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.99, votes: 102401, date: AnswerDate(year: 2024, month: 7, day: 22), globalRank: 1),
                Answer(answer: "Test Answer 2\n\n\n...more text...", prompt: "Prompt 2", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.81, votes: 22, date: AnswerDate(year: 2024, month: 7, day: 21), globalRank: 2),
                Answer(answer: "Test Answer 3 abcdef ghi\n...more text...", prompt: "Prompt 3", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.05, votes: 22, date: AnswerDate(year: 2024, month: 7, day: 20), globalRank: 3),
                Answer(answer: "Test Answer 1------------ ------------", prompt: "Prompt 1", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.7, votes: 24, date: AnswerDate(year: 2024, month: 7, day: 19), globalRank: 89)
            ]
        ).environmentObject(Prompt("This is a test prompt ... and now it is done?", AnswerDate(year: 2024, month: 8, day: 2)))
    }
}
