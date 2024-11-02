import SwiftUI

struct ProfileView: View {
        
    @EnvironmentObject var appEngine: AppEngine
    
    var otherUser: User = User()
    
    var user: User {
        return isSelf ? appEngine.user : otherUser
    }
    
    @State private var answerListControl = 0

    var isSelf: Bool
    
    let DEFAULT_USERNAME: String = "[username]"
    let MAX_LENGTH: Int = 20
    
    init() {
        self.isSelf = true
    }
    
    init(_ otherUser: User) {
        self.otherUser = otherUser
        self.isSelf = false
    }
    
    var body: some View {
        ZStack{
            Image("profile")
                .resizable()
                .scaledToFill() // Ensures the image fills the entire view
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Takes the full screen size
                .ignoresSafeArea()
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .blur(radius: 10)
            
            VStack(spacing: 5) {
                if isSelf {
                    TextField(user.nickname == "" ? DEFAULT_USERNAME : user.nickname, text: $appEngine.user.nickname)
                        .roundedTitleFont()
                        .textFieldStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .onChange(of: user.nickname) {
                            if user.nickname.count > MAX_LENGTH {
                                appEngine.user.nickname = String(user.nickname.prefix(MAX_LENGTH))
                            }
                            
                        }
                        .onSubmit {
                            AppEngine.updateNickname(appEngine.user)
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
                            .roundedTitleFont()

                        Text("Recent")
                            .subTitleFont()
                    }
                    Spacer()
                    VStack {
                        Text(user.getAverageWinPercentage())
                            .roundedTitleFont()

                        Text("Average")
                            .subTitleFont()
                    }
                    Spacer()
                    VStack {
                        Text(user.getBestWinPercentage())
                            .roundedTitleFont()

                        Text("Best")
                            .subTitleFont()
                    }
                    Spacer()
                }
                Picker("Options", selection: $answerListControl) {
                    Text("Recent").tag(0)
                        .subTitleFont()
                    Text("Highest").tag(1)
                        .subTitleFont()

                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List {
                    ForEach(0..<user.answers.count, id: \.self) { index in
                        let answer: Answer = user.getAnswer(index, answerListControl == 0 ? .DATE : .WIN_PERCENTAGE)
                        ProfileAnswerView(answer)
                            .listRowBackground(Color.white.opacity(0.3)) // Makes the row background transparent                        
                    }

                }
                .listStyle(PlainListStyle())


                .refreshable {
                    /*
                     TO-DO
                     */
                }
            }
            .padding(.top, 80)
        }
    }
}
