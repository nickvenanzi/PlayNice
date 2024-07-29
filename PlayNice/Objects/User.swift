import SwiftUI

class User: ObservableObject {
    
    var firebaseID: String = ""
    var docID: String = ""
    
    @Published var nickname: String = ""
    @Published var following: Set<String> = Set()
    @Published var answers: [AnswerDate: Answer] = [:]
    @Published var orderedAnswersByDate: [Answer] = []
    @Published var orderedAnswersByWinPercentage: [Answer] = []
    
    func orderAnswers() {
        let answerArray = answers.map { (key: AnswerDate, value: Answer) in value }
        orderedAnswersByDate = answerArray.sorted { ans1, ans2 in
            ans1 > ans2
        }
        orderedAnswersByWinPercentage = answerArray.sorted { ans1, ans2 in
            ans1.winPercentage > ans2.winPercentage
        }
    }
    
    func getAnswer(_ at: Int, _ by: Order) -> Answer {
        if by == .DATE {
            return orderedAnswersByDate[at]
        } else {
            return orderedAnswersByWinPercentage[at]
        }
    }
    
    func getBestWinPercentage() -> String {
        guard !answers.isEmpty else {
            return "N/A"
        }
        return "\(Int(orderedAnswersByWinPercentage[0].winPercentage * 100))%"
    }
    
    func getAverageWinPercentage() -> String {
        guard !answers.isEmpty else {
            return "N/A"
        }
        let total = orderedAnswersByWinPercentage.reduce(0, { sum, nextAnswer in
            sum + nextAnswer.winPercentage
        })
        let average = total / Float(orderedAnswersByWinPercentage.count)
        return "\(Int(average * 100))%"
    }
    
    func getPreviousWinPercentage() -> String {
        guard !answers.isEmpty else {
            return "N/A"
        }
        
        return "\(Int(orderedAnswersByDate[0].winPercentage * 100))%"
    }
    
    func getMedals() -> String {
        var first = ""
        var second = ""
        var third = ""
        for ans in answers.values {
            if ans.globalRank == 1 {
                first += "🥇"
            } else if ans.globalRank == 2 {
                second += "🥈"
            } else if ans.globalRank == 3 {
                third += "🥉"
            }
        }
        return first + second + third
    }
    
    func doesFollow(_ otherDocID: String) -> Bool {
        return following.contains(otherDocID)
    }
}

enum Order {
    case DATE
    case WIN_PERCENTAGE
}
