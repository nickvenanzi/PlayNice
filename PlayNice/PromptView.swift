import SwiftUI

struct PromptView: View {
    @State private var userAnswer: String = ""
    
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
                HStack(alignment: .center, spacing: 10) {
                    TextField("Enter a funny response", text: $userAnswer,  axis: .vertical)
                        .lineLimit(1...10)
                        .padding(4)
                        .cornerRadius(8)
                        .autocorrectionDisabled(true)
                        .textFieldStyle(.roundedBorder)
                    if !userAnswer.isEmpty {
                        Button {
                            self.dismissKeyboard()
                            // Handle answer submission
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                appEngine.submitAnswer(userAnswer)
                            }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                                .font(.body.weight(.semibold))
                        }
                    }
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
