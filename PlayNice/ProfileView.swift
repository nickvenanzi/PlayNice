import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var user: User
    @State private var answerListControl = 0

    var isSelf: Bool
    let DEFAULT_USERNAME: String = "[username]"
    let MAX_LENGTH: Int = 20
    
    let recentItems = ["Item 1", "Item 2", "Item 3"]
    let highestItems = ["Item A", "Item B", "Item C"]
    init(isSelf: Bool) {
        self.isSelf = isSelf
    }
    
    var body: some View {
        VStack(spacing: 5) {
            if self.isSelf {
                TextField(user.nickname == "" ? DEFAULT_USERNAME : user.nickname, text: $user.nickname)
                    .font(.largeTitle)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .onChange(of: user.nickname) {
                        if user.nickname.count > MAX_LENGTH {
                            user.nickname = String(user.nickname.prefix(MAX_LENGTH))
                        }
                    }
                    .onSubmit {
                        /*
                         TO-DO fill in updating database
                         */
                    }
            } else {
                Text(user.nickname)
                    .font(.largeTitle)
            }
            let medals: String = user.getMedals()
            if (!medals.isEmpty) {
                Text(medals)
            }
    
            HStack {
                Spacer()
                VStack {
                    Text(user.getPreviousWinPercentage())
                        .font(.largeTitle)

                    Text("Recent")
                        .font(.body)
                }
                Spacer()
                VStack {
                    Text(user.getAverageWinPercentage())
                        .font(.largeTitle)

                    Text("Average")
                        .font(.body)
                }
                Spacer()
                VStack {
                    Text(user.getBestWinPercentage())
                        .font(.largeTitle)

                    Text("Best")
                        .font(.body)
                }
                Spacer()
            }
            Picker("Options", selection: $answerListControl) {
                Text("Recent").tag(0)
                Text("Highest").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            List {
                ForEach(0..<user.answers.count, id: \.self) { index in
                    let answer: Answer = user.getAnswer(index, answerListControl == 0 ? .DATE : .WIN_PERCENTAGE)
                    ProfileAnswerView(answer)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var user: User {
        let user = User()
        user.answers = [
            AnswerDate(year: 2024, month: 7, day: 22): Answer(answer: "Test Answer 1------------ ------------ blah blah blah is there a god in this dumb universe?", prompt: "Prompt 1 is the following question for ", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.7, votes: 2000, date: AnswerDate(year: 2024, month: 7, day: 22), globalRank: 111),
            AnswerDate(year: 2024, month: 7, day: 21): Answer(answer: "Test Answer 2\n\n\n\n...more text...", prompt: "Prompt 2", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.81, votes: 22, date: AnswerDate(year: 2024, month: 7, day: 21), globalRank: 3),
            AnswerDate(year: 2024, month: 7, day: 20): Answer(answer: "Test Answer 3 abcdef ghi\n...more text...", prompt: "Prompt 3", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.05, votes: 22, date: AnswerDate(year: 2024, month: 7, day: 20), globalRank: 89),
            AnswerDate(year: 2024, month: 7, day: 19): Answer(answer: "Test Answer 1------------ ------------", prompt: "Prompt 1", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.7, votes: 24, date: AnswerDate(year: 2024, month: 7, day: 19), globalRank: 1),
            AnswerDate(year: 2024, month: 7, day: 18): Answer(answer: "Test Answer 2\n\n\n\n...more text...", prompt: "Prompt 2", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.81, votes: 22, date: AnswerDate(year: 2024, month: 7, day: 18), globalRank: 8),
            AnswerDate(year: 2024, month: 7, day: 17): Answer(answer: "Test Answer 3\n...more text...", prompt: "Prompt 3", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.05, votes: 22, date: AnswerDate(year: 2024, month: 7, day: 17))
        ]
        user.orderAnswers()
        return user
    }
    
    static var previews: some View {
        ProfileView(isSelf: true).environmentObject(user)
    }
}
