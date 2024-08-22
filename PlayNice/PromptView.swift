import SwiftUI

struct PromptView: View {
    @State private var userAnswer: String = ""

    @StateObject var alert: SubmitAlert = SubmitAlert()
    @EnvironmentObject var appEngine: AppEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(appEngine.prompt.text)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            if appEngine.prompt.submitted {
                Text(appEngine.user.answers[appEngine.today]?.answer ?? userAnswer)
                    .font(.title3)
            } else {
                TextField("Write your answer here...", text: $userAnswer)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onSubmit {
                        self.dismissKeyboard()
                        // Handle answer submission
                        alert.presented = true
                        appEngine.submitAnswer(userAnswer)
                        
                    }
                    .alert(isPresented: $alert.presented) {
                        Alert(
                            title: Text("Answer Submitted"),
                            message: Text(userAnswer),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            }
            Spacer()
        }
        .padding()
        .onTapGesture {
            self.dismissKeyboard()
        }
    }
}

class SubmitAlert: ObservableObject {
    @Published var presented: Bool = false
}
