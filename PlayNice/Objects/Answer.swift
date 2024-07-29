import Foundation

struct Answer: Hashable, Comparable, Codable, Identifiable {
    var id = UUID()
    
    let answer: String
    let prompt: String
    let author: String
    let authorDocID: String
    var winPercentage: Float
    var votes: Int
    var date: AnswerDate
    var globalRank: Int?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(authorDocID)
        hasher.combine(date)
    }
    
    static func == (lhs: Answer, rhs: Answer) -> Bool {
        return lhs.authorDocID == rhs.authorDocID && lhs.date == rhs.date
    }
    
    static func < (lhs: Answer, rhs: Answer) -> Bool {
        return lhs.date < rhs.date
    }
    
    func getWinPercentageString() -> String {
        return "\(Int(winPercentage * 100))%"
    }
        
    func getYearMonthDay() -> [String] {
        var monthString: String
        switch (date.month) {
            case 1:
                monthString = "January"
            case 2:
                monthString = "February"
            case 3:
                monthString = "March"
            case 4:
                monthString = "April"
            case 5:
                monthString = "May"
            case 6:
                monthString = "June"
            case 7:
                monthString = "July"
            case 8:
                monthString = "August"
            case 9:
                monthString = "September"
            case 10:
                monthString = "October"
            case 11:
                monthString = "November"
            case 12:
                monthString = "December"
            default:
                monthString = "January"
        }
        return [String(date.year), monthString, String(date.day)]
    }
}

struct AnswerDate: Hashable, Comparable, Codable {
    
    var year: Int = 2024
    var month: Int = 1
    var day: Int = 1
    
    static func < (lhs: AnswerDate, rhs: AnswerDate) -> Bool {
        // same year
        if (lhs.year == rhs.year) {
            // same month
            if (lhs.month == rhs.month) {
                return lhs.day < rhs.day
            }
            return lhs.month < rhs.month
        }
        return lhs.year < rhs.year
    }
    
    func getMonthString() -> String {
        switch (month) {
            case 1:
                return "January"
            case 2:
                return "February"
            case 3:
                return "March"
            case 4:
                return "April"
            case 5:
                return "May"
            case 6:
                return "June"
            case 7:
                return "July"
            case 8:
                return "August"
            case 9:
                return "September"
            case 10:
                return "October"
            case 11:
                return "November"
            case 12:
                return "December"
            default:
                return "January"
        }
    }
}
