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

struct AnswerDate: Hashable, Comparable, Codable, Equatable {
    
    var year: Int = 2024
    var month: Int = 1
    var day: Int = 1
    
    /*
     Default initializer creates an AnswerDate object associated with today's date
     */
    init() {
        let pieces = Date().description.split(separator: " ")[0].split(separator: "-")
        self.year = Int(String(pieces[0])) ?? 0
        self.month = Int(String(pieces[1])) ?? 0
        self.day = Int(String(pieces[2])) ?? 0
    }
    
    /*
     initializer creates an AnswerDate object associated with year/month/day
     */
    init(_ year: Int, _ month: Int, _ day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
    
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
    
    static func == (lhs: AnswerDate, rhs: AnswerDate) -> Bool {
        return lhs.day == rhs.day && lhs.month == rhs.month && lhs.year == rhs.year
    }
    
    static func yesterday() -> AnswerDate {
        return AnswerDate().dayBefore()
    }
    
    func dayBefore() -> AnswerDate {
        let thirtyOne: Set<Int> = Set([1,3,5,7,8,10,12])
        let thirty: Set<Int> = Set([4,6,9,11])
        
        var yesterday = AnswerDate(year, month, day - 1)
        
        if yesterday.day == 0 {
            yesterday.month -= 1
            if yesterday.month == 0 {
                yesterday.month = 12
                yesterday.year -= 1
            }
            if (thirtyOne.contains(yesterday.month)) {
                yesterday.day = 31
            } else if (thirty.contains(yesterday.month)) {
                yesterday.day = 30
            } else if (yesterday.year % 4 == 0) {
                yesterday.day = 29
            } else {
                yesterday.day = 28
            }
        }
        return yesterday
    }
    
    func dayAfter() -> AnswerDate {
        let thirtyOne: Set<Int> = Set([1,3,5,7,8,10,12])
        
        var tomorrow = AnswerDate(year, month, day + 1)
        
        if (
            (tomorrow.day > 31) ||
            (tomorrow.day > 30 && !thirtyOne.contains(tomorrow.month)) ||
            (tomorrow.day > 29 && tomorrow.month == 2) ||
            (tomorrow.day > 28 && tomorrow.month == 2 && tomorrow.year % 4 != 0)
        ) {
            tomorrow.day = 1
            tomorrow.month += 1
        }
        
        if tomorrow.month > 12 {
            tomorrow.month = 1
            tomorrow.year += 1
        }
        return tomorrow
    }
    
    static func fromString(_ dateString: String) -> AnswerDate {
        let pieces = dateString.components(separatedBy: "-")
        return AnswerDate(Int(pieces[0]) ?? 0, Int(pieces[1]) ?? 0, Int(pieces[2]) ?? 0)
    }
    
    func toString() -> String {
        return "\(year)-\(month)-\(day)"
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
