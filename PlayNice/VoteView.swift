import SwiftUI

struct VoteView: View {
    
    @EnvironmentObject var appEngine: AppEngine
    
    var body: some View {
        ZStack{
            Image("voting")
                .resizable()
                .scaledToFill() // Ensures the image fills the entire view
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Takes the full screen size
                .ignoresSafeArea()
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .blur(radius: 10)
            VStack{
                Text(appEngine.prompt.text)
                    .roundedTitleFont() // Applies the custom font modifier
                    .padding(.top, 20)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                ScrollView {
                    
                    if appEngine.currentAnswers.count == 0 {
                        Text("No more answers available.  Come back later for more!")
                    }
                    
                    ForEach(0..<appEngine.currentAnswers.count, id: \.self) { index in
                        AnswerOptionView(
                            answer: appEngine.currentAnswers[index],
                            selectedAnswer: appEngine.selectedAnswer,
                            isSelected: appEngine.selectedAnswer == index
                        )
                        .onTapGesture {
                            appEngine.castVotes(winningIndex: index)
                            withAnimation(.easeInOut) {
                                appEngine.selectedAnswer = index
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                appEngine.getAnswerSet()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .refreshable {
                    if appEngine.areCurrentAnswersStale() {
                        appEngine.getAnswerSet()
                    }
                }
            }
            .padding(.top, 120)

        }
    }
}

struct AnswerOptionView: View {
    let answer: Answer
    var selectedAnswer: Int?
    var isSelected: Bool
    static let SELECTED_COLOR: Color = Color(red: 0, green: 1, blue: 0, opacity: 0.5)

    var body: some View {
        VStack {
            HStack {
                Text(answer.answer)
                    .roundedTitleFont() // Applies the custom font modifier
                    .padding()
                    .background(isSelected  ? Self.SELECTED_COLOR : Color.gray.opacity(0.2))

                    .cornerRadius(10)
                Spacer()
            }
            .padding(.vertical, 5)

            if let _ = selectedAnswer {
                AnswerPercentageBar(answer, includeVotes: false, progress: 0, color: isSelected ? Self.SELECTED_COLOR: .gray)
                Spacer()
            }
        }
    }
}
