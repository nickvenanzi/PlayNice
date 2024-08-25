import SwiftUI
import FirebaseFirestore

struct DeveloperView: View {

    @EnvironmentObject var appEngine: AppEngine
    @StateObject private var devService: DeveloperService = DeveloperService()
    
    var body: some View {
        NavigationView {
            List(devService.prompts) { fsPrompt in
                NavigationLink(destination: DeveloperPromptView(fsPrompt: fsPrompt)) {
                    Text(fsPrompt.date)
                    Text(fsPrompt.prompt)
                }
            }
            .navigationTitle("Prompts")
        }
    }
    
    
}

struct DeveloperPromptView: View {
    let fsPrompt: FSPrompt
        
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Display the prompt date
            Text(fsPrompt.date)
                .font(.headline)
            
            // TextField for editing the prompt
            TextField(fsPrompt.prompt, text: fsPrompt.$prompt, onCommit: {
                updatePrompt()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            
            // List of answers
            if let answers = fsPrompt.answers {
                List(answers, id: \.self) { answer in
                    Text(answer)
                }
            } else {
                Text("No answers generated")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .navigationTitle("Prompt")
    }
        
    private func updatePrompt() {
        guard let documentID = prompt.id else { return }
        
        db.collection("prompts").document(documentID).updateData([
            "prompt": editedPrompt
        ]) { error in
            if let error = error {
                print("Error updating prompt: \(error)")
            } else {
                // Successfully updated prompt
                print("Prompt successfully updated")
                prompt.name = editedPrompt
            }
        }
    }
}

class DeveloperService: ObservableObject {
    @Published var prompts: [FSPrompt] = []
    private var listener: ListenerRegistration?
    
    init() {
        if listener != nil {
            return
        }
        listener = AppEngine.db.collection("prompts").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching prompts: \(error)")
                return
            }
            
            self.prompts = snapshot?.documents.compactMap { document in
                try? document.data(as: FSPrompt.self)
            } ?? []
        }
    }
}

struct FSPrompt: Identifiable, Codable {
    @DocumentID var id: String?
    var date: String
    var count: Int
    var prompt: String
    var answers: [String]?
}
