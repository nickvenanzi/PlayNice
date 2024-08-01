import SwiftUI

struct PromptView: View {
    @State private var userAnswer: String = ""
    @State private var showAlert: Bool = false

    @State var prompt: String = "What is your favorite programming language?"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(prompt)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)

            TextField("Write your answer here...", text: $userAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: {
                // Handle answer submission
                showAlert = true
            }) {
                Text("Submit")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Answer Submitted"),
                    message: Text("Your answer has been submitted."),
                    dismissButton: .default(Text("OK"))
                )
            }

            Spacer()
        }
        .padding()
    }
}

struct PromptView_Previews: PreviewProvider {
    static var previews: some View {
        PromptView()
    }
}

