import SwiftUI

struct PromptView: View {
    @State private var userAnswer: String = ""
    @State private var textViewHeight: CGFloat = 40  // Initial height
    
    private var textViewWidth: CGFloat = UIScreen.main.bounds.width - 32

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
                TextEditor(text: $userAnswer)
                    .padding(4)
                    .frame(height: textViewHeight) // Dynamic height
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .autocorrectionDisabled(true)
                    .onChange(of: userAnswer) {
                        recalculateHeight()
                    }
                
                Button(action: {
                    self.dismissKeyboard()
                    // Handle answer submission
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        appEngine.submitAnswer(userAnswer)
                    }
                }) {
                    Text("Submit")
                        .frame(maxWidth: .infinity)  // Same width as the TextEditor
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
        }
        .padding()
        .onTapGesture {
            self.dismissKeyboard()
        }
    }
    
    private func recalculateHeight() {
        let size = CGSize(width: textViewWidth, height: .infinity)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
        let boundingRect = NSString(string: userAnswer).boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        textViewHeight = max(40, boundingRect.height + 24) // Update the height with padding
    }
}
