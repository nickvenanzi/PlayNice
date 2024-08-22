import SwiftUI

struct DebugView: View {
    
    @EnvironmentObject var appEngine: AppEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(appEngine.debugCounter)")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text("Today: \(appEngine.today.toString())")
                .font(.title3)
            
            Spacer()
        }
        .padding()
    }
}
