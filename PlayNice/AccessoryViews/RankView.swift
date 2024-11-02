import SwiftUI

struct RankView: View {
    
    var rank: Int
    
    init(_ rank: Int) {
        self.rank = rank
    }
    
    var body: some View {
        if rank <= 3 {
            return AnyView(Text(rankEmoji(for: rank))
                .font(.largeTitle))
        } else {
            var trail = "th"
            let rankMod100 = rank % 100
            let rankMod10 = rank % 10
            if rankMod10 == 1 && rankMod100 != 11 {
                trail = "st"
            } else if rankMod10 == 2 && rankMod100 != 12 {
                trail = "nd"
            } else if rankMod10 == 3 && rankMod100 != 13 {
                trail = "rd"
            }
            return AnyView(HStack(spacing: 0) {
                Text("\(rank)")
                    .roundedTitleFont() // Applies the custom font modifier
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(trail)
                    .font(.caption)
                    .baselineOffset(6)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            })
        }
    }
        
    private func rankEmoji(for rank: Int) -> String {
        switch rank {
        case 1:
            return "🥇"
        case 2:
            return "🥈"
        case 3:
            return "🥉"
        default:
            return "\(rank)th"
        }
    }
}

