import SwiftUI

class RankingViewModel: ObservableObject {
    @Published var prompt: String = "What was your best achievement yesterday?"
    @Published var answers: [Answer] = [
        Answer(answer: "Test Answer 1------------ ------------", prompt: "Prompt 1", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.7, votes: 24923986, date: AnswerDate(year: 2024, month: 7, day: 22), globalRank: 1),
        Answer(answer: "Test Answer 2\n\n\n\n...more text...", prompt: "Prompt 2", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.81, votes: 22, date: AnswerDate(year: 2024, month: 7, day: 21), globalRank: 3),
        Answer(answer: "Test Answer 3 abcdef ghi\n...more text...", prompt: "Prompt 3", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.05, votes: 22, date: AnswerDate(year: 2024, month: 7, day: 20), globalRank: 89),
        Answer(answer: "Test Answer 1------------ ------------", prompt: "Prompt 1", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.7, votes: 24, date: AnswerDate(year: 2024, month: 7, day: 19), globalRank: 1),
        Answer(answer: "Test Answer 2\n\n\n\n...more text...", prompt: "Prompt 2", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.81, votes: 22, date: AnswerDate(year: 2024, month: 7, day: 18), globalRank: 8),
        Answer(answer: "Test Answer 3\n...more text...", prompt: "Prompt 3", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.05, votes: 22, date: AnswerDate(year: 2024, month: 7, day: 17))
    ]
}

struct RankingView: View {
    @StateObject private var viewModel = RankingViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.prompt)
                .font(.title)
                .padding()

            List(viewModel.answers) { answer in
                RankingAnswerView(answer)
            }
        }
    }
    
    
}

struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        RankingView()
    }
}


