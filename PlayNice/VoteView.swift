import SwiftUI

struct VoteView: View {
    @State private var selectedAnswer: Int? = nil
    let prompt: String = "What is your favorite programming language?"
    let answers: [String] = ["Swift\nhellow from the other siiiiiiide", "Python", "JavaScript", "Java is clearly the best programming language there isnt even remotely a question on this subject matter that I could speak on"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(prompt)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.horizontal)

            ForEach(0..<answers.count, id: \.self) { index in
                AnswerOptionView(
                    answer: answers[index],
                    isSelected: selectedAnswer == index
                )
                .onTapGesture {
                    selectedAnswer = index
                }
                .padding(.horizontal)
            }

            Spacer()

            if let selectedAnswer = selectedAnswer {
                Text("Selected Answer: \(answers[selectedAnswer])")
                    .font(.headline)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}

struct AnswerOptionView: View {
    let answer: String
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(answer)
                .font(.body)
                .padding()
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? Color.white : Color.black)
                .cornerRadius(10)
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

struct VoteView_Previews: PreviewProvider {
    static var previews: some View {
        VoteView()
    }
}
