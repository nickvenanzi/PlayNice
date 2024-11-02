import SwiftUI

struct PromptView: View {
    @State private var userAnswer: String = ""
    
    @EnvironmentObject var appEngine: AppEngine

    var body: some View {
        ZStack{
            Image("thinking")
                .resizable()
                .scaledToFill() // Ensures the image fills the entire view
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Takes the full screen size
                .ignoresSafeArea()
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .blur(radius: 10)
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                Text(appEngine.prompt.text)
                    .roundedTitleFont() // Applies the custom font modifier
                    .padding(.leading, 20)
                if appEngine.prompt.submitted {
                    Text(appEngine.user.answers[appEngine.today]?.answer ?? userAnswer)
                        .font(.title3)
                } else {
                    HStack(alignment: .center, spacing: 10) {
                        TextField("Enter a funny response", text: $userAnswer, axis: .vertical)
                            .lineLimit(1...10)
                            .padding(.leading, 20)
                            .autocorrectionDisabled(true)
                            .roundedTitleFont() // Applies the custom font modifier

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
                                    .foregroundColor(.white)
                                    .font(.body.weight(.semibold))
                            }
                            .transition(.scale) // Adds a scale transition when button appears/disappears
                            .animation(.spring(), value: userAnswer) // Smooth animation for button appearance
                        }
                    }
                    .padding(.horizontal)
                    Spacer()

                }
                Spacer()
            }
            //.padding(.top, 100)
            .onTapGesture {
                self.dismissKeyboard()
            }
            
        }
        
    }
}
