import SwiftUI

struct ProfileAnswerView: View {
    
    var answer: Answer
    
    init(_ answer: Answer) {
        self.answer = answer
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                DateView(answer.date).frame(maxHeight: 50)

                Text(answer.prompt)
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(.leading, 5)
                if let rank = answer.globalRank {
                    Spacer()
                    RankView(rank)
                        .frame(alignment: .trailing)
                }
            }
            
            Text(answer.answer)
                .font(.body)
                .padding(.top, 10)
            
            HStack {
                Text("\(answer.votes) votes")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 70)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                PercentageBar(percentage: Double(answer.winPercentage))
                Text("\(Int(answer.winPercentage*100))%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }.padding(.top, 10)
        }
    }
}

struct ProfileAnswerView_Previews: PreviewProvider {
    static var answer: Answer =
        Answer(answer: "Test Answer 2lsjdfhlaksdjhfalksdjhflajshdflkjahsdfs\n...more text...", prompt: "What is something you might find in President Joe Biden's search history?", author: "nick v", authorDocID: "xyzabc", winPercentage: 0.81, votes: 22222, date: AnswerDate(year: 2024, month: 7, day: 21), globalRank: 3)
    
    static var previews: some View {
        ProfileAnswerView(answer).frame(height: 180)
    }
}


//import SwiftUI
//
//struct ProfileAnswerView: View {
//    
//    var answer: Answer
//    static let CORRECT_COLOR: Color = .green
//    static let INCORRECT_COLOR: Color = .red
//    
//    init(_ answer: Answer) {
//        self.answer = answer
//    }
//    
//    var body: some View {
//        HStack(spacing: 20) {
//            VStack {
//                // Calendar View on the Left
//                DateView(answer.date).frame(maxHeight: 50)
//                
//                HStack {
//                    PercentageBar(percentage: Double(answer.winPercentage))
//                    Text("\(Int(answer.winPercentage * 100))%")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .lineLimit(1)
//                        .minimumScaleFactor(0.5)
//                }
//                .frame(maxWidth: 50)
//            }
//            
//            // Text Views on the Right
//            VStack(alignment: .leading) {
//                HStack {
//                    Text(answer.prompt)
//                        .font(.body)
//                        .fontWeight(.bold)
//                    if let rank = answer.globalRank, rank <= 3 {
//                        Spacer()
//                        if rank == 1 {
//                            Text(" 🥇 ").font(.largeTitle)
//                        } else if rank == 2 {
//                            Text(" 🥈 ").font(.largeTitle)
//                        } else {
//                            Text(" 🥉 ").font(.largeTitle)
//                        }
//                    }
//                }
//                
//                Text(answer.answer)
//                    .font(.body)
//            }
//            .multilineTextAlignment(.leading)
//        }
//    }
//}
//
//struct ProfileAnswerView_Previews: PreviewProvider {
//    static var answer: Answer =
//        Answer(answer: "Test Answer 2lsjdfhlaksdjhfalksdjhflajshdflkjahsdfs\n...more text...\n...more text...\n...more text...\n...more text...", prompt: "What is something you might find in President Joe Biden's search history?", author: "nick v", authorDocID: "xyzabc", winPercentage: 1, votes: 22, date: AnswerDate(year: 2024, month: 7, day: 21), globalRank: 3)
//    
//    static var previews: some View {
//        ProfileAnswerView(answer)
//    }
//}
