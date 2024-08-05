import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var userEngine: UserEngine
    var otherUser: User = User()
    
    var user: User {
        return isSelf ? userEngine.user : otherUser
    }

    @State private var answerListControl = 0

    var isSelf: Bool
    let DEFAULT_USERNAME: String = "[username]"
    let MAX_LENGTH: Int = 20

    init(isSelf: Bool) {
        self.isSelf = isSelf
    }
    
    var body: some View {
        VStack(spacing: 5) {
            if self.isSelf {
                TextField(user.nickname == "" ? DEFAULT_USERNAME : user.nickname, text: $userEngine.user.nickname)
                    .font(.largeTitle)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .onChange(of: user.nickname) {
                        if user.nickname.count > MAX_LENGTH {
                            userEngine.user.nickname = String(user.nickname.prefix(MAX_LENGTH))
                        }
                    }
                    .onSubmit {
                        UserEngine.updateNickname()
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
