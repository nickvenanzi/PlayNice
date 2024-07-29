import SwiftUI

struct DateView: View {
    let month: String
    let day: String
    let year: String
    
    init(_ answerDate: AnswerDate) {
        switch (answerDate.month) {
        case 1:
            month = "JAN"
        case 2:
            month = "FEB"
        case 3:
            month = "MAR"
        case 4:
            month = "APR"
        case 5:
            month = "MAY"
        case 6:
            month = "JUN"
        case 7:
            month = "JUL"
        case 8:
            month = "AUG"
        case 9:
            month = "SEP"
        case 10:
            month = "OCT"
        case 11:
            month = "NOV"
        case 12:
            month = "DEC"
        default:
            month = "DEF"
        }
        day = answerDate.day < 10 ? "0\(answerDate.day)" : "\(answerDate.day)"
        year = " '\(answerDate.year - 2000)"
    }
    
    var body: some View {
        GeometryReader { geometry in
            let sideLength = min(geometry.size.width, geometry.size.height)
            
            VStack(spacing: 0) {
                Text(month + year)
                    .font(.system(size: sideLength * 0.2, weight: .bold, design: .default))
                    .foregroundColor(.black)
                    .frame(width: sideLength, height: sideLength * 0.3)
                    .background(Color.gray)
                
                Text(day)
                    .font(.system(size: sideLength * 0.4, weight: .bold, design: .default))
                    .foregroundColor(.black)
                    .frame(width: sideLength, height: sideLength * 0.7)
                    .background(Color.white)
            }
            .frame(width: sideLength, height: sideLength)
            .cornerRadius(sideLength * 0.1)
            .shadow(radius: sideLength * 0.05)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}


struct MonthDayView_Previews: PreviewProvider {
    static var previews: some View {
        DateView(AnswerDate(year: 2024, month: 7, day: 2))
    }
}
