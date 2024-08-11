import SwiftUI

struct PromptView: View {
    @State private var userAnswer: String = ""
    @State private var showAlert: Bool = false

    @EnvironmentObject var promptEngine: PromptEngine
    @EnvironmentObject var userEngine: UserEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(promptEngine.prompt.text)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            if promptEngine.prompt.submitted {
                Text(userAnswer)
                    .font(.title3)
            } else {
                TextField("Write your answer here...", text: $userAnswer)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onSubmit {
                        self.dismissKeyboard()
                        // Handle answer submission
                        showAlert = true
                        userEngine.submitPrompt(promptEngine.prompt.text, userAnswer) {
                            promptEngine.prompt.submitted = true
                        }
                    }
                    .alert(isPresented: $showAlert) {
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
