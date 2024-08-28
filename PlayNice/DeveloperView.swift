import SwiftUI
import FirebaseFirestore
import FirebaseMessaging

struct DeveloperView: View {

    @EnvironmentObject var appEngine: AppEngine
    @StateObject private var devService: DeveloperService = DeveloperService()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Button(action: {
                    let max = devService.prompts.max { pair1, pair2 in
                        AnswerDate.fromString(pair1.key) < AnswerDate.fromString(pair2.key)
                    }
                    var maxDay = AnswerDate.fromString(max?.value.date ?? AnswerDate().toString())
                    if maxDay < AnswerDate() {
                        maxDay = AnswerDate()
                    }
                    let nextDay = maxDay.dayAfter().toString()
                    devService.prompts[nextDay] = FSPrompt(date: nextDay, prompt: "Type in a prompt")
                    print("Button pressed")
                    print("Added new item to devService?: \(devService.prompts[nextDay]?.date ?? "Nope")")
                }) {
                    Image(systemName: "plus")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                LazyVGrid(columns: [GridItem(.fixed(50)), GridItem(.flexible())], spacing: 20) {
                    ForEach(devService.prompts.values.sorted {
                        AnswerDate.fromString($0.date) > AnswerDate.fromString($1.date)
                    }, id: \.self) { fsPrompt in
                        DateView(AnswerDate.fromString(fsPrompt.date))
                            
                        NavigationLink(destination: DeveloperPromptView(date: fsPrompt.date).environmentObject(devService)) {
                            Text(fsPrompt.prompt)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Prompts", displayMode: .inline)
        }
    }
}

struct DeveloperPromptView: View {
    var date: String
    @State var editedPrompt: String = ""
    @EnvironmentObject var devService: DeveloperService
        
    init(date: String) {
        self.date = date
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            let prompt = devService.prompts[date] ?? FSPrompt(date: "1999-2-11", prompt: "Error")
            HStack {
                DateView(AnswerDate.fromString(prompt.date))
                    .frame(maxWidth: 50)
                    .padding(.horizontal)
                
                if AnswerDate.fromString(prompt.date) > AnswerDate() {
                    TextField(prompt.prompt, text: $editedPrompt, onCommit: {
                        updatePrompt()
                    })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(prompt.prompt)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            if let answers = devService.prompts[date]?.answers {
                List(answers, id: \.self) { answer in
                    Text(answer)
                }
            } else {
                Text("No answers generated")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Prompt")
    }
        
    private func updatePrompt() {
        guard let documentID = devService.prompts[date]?.id else { return }
        
        AppEngine.db.collection("prompts").document(documentID).updateData([
            "prompt": editedPrompt,
            "answers": FieldValue.delete()
        ]) { error in
            if let error = error {
                print("Error updating prompt: \(error)")
            } else {
                // Successfully updated prompt
                print("Prompt successfully updated")
                self.devService.prompts[self.date]?.answers = nil
                self.devService.prompts[self.date]?.prompt = editedPrompt
            }
        }
    }
}

class DeveloperService: ObservableObject {
    @Published var prompts: [String: FSPrompt] = [:]
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
            print("Found \(snapshot?.documents.count ?? 0) documents in the prompts collection")
            self.prompts = Dictionary(uniqueKeysWithValues: snapshot?.documents.compactMap { document in
                try? document.data(as: FSPrompt.self)
            }.map { prompt in
                (prompt.date, prompt) // Create a tuple with 'date' as the key and 'prompt' as the value
            } ?? [])
        }
    }
    
    deinit {
        listener?.remove()
        listener = nil
    }
}

struct FSPrompt: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var date: String
    var count: Int?
    var prompt: String
    var answers: [String]?
}


//import SwiftUI
//import FirebaseFirestore
//
//struct DeveloperView: View {
//
//    @EnvironmentObject var appEngine: AppEngine
//    @StateObject private var devService: DeveloperService = DeveloperService()
//    
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(devService.prompts.values.sorted {
//                    AnswerDate.fromString($0.date) > AnswerDate.fromString($1.date)
//                }, id: \.self) { fsPrompt in
//                    NavigationLink(destination: DeveloperPromptView(date: fsPrompt.date).environmentObject(devService)) {
//                        Text(fsPrompt.date)
//                        Text(fsPrompt.prompt)
//                    }
//                }
//                .onMove(perform: move)
//            }
//            .navigationBarTitle("Editable List", displayMode: .inline)
//            .environment(\.editMode, .constant(.active)) // Always keep edit mode active
//        }
//    }
//
//    private func move(from source: IndexSet, to destination: Int) {
//        let promptsOrdered = devService.prompts.values.sorted {
//            AnswerDate.fromString($0.date) > AnswerDate.fromString($1.date)
//        }
//        let newDestination = promptsOrdered[destination]
//        items.move(fromOffsets: source, toOffset: destination)
//    }
//    
//    
//}
//
//struct DeveloperPromptView: View {
//    var date: String
//    @State var editedPrompt: String = ""
//    @EnvironmentObject var devService: DeveloperService
//        
//    init(date: String) {
//        self.date = date
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            // Display the prompt date
//            Text(devService.prompts[date]?.date ?? "Error")
//                .font(.headline)
//            
//            // TextField for editing the prompt
//            TextField(devService.prompts[date]?.prompt ?? "", text: $editedPrompt, onCommit: {
//                updatePrompt()
//            })
//            .textFieldStyle(RoundedBorderTextFieldStyle())
//            .padding()
//            
//            // List of answers
//            if let answers = devService.prompts[date]?.answers {
//                List(answers, id: \.self) { answer in
//                    Text(answer)
//                }
//            } else {
//                Text("No answers generated")
//                    .foregroundColor(.gray)
//            }
//            Spacer()
//        }
//        .padding()
//        .navigationTitle("Prompt")
//    }
//        
//    private func updatePrompt() {
//        guard let documentID = devService.prompts[date]?.id else { return }
//        
//        AppEngine.db.collection("prompts").document(documentID).updateData([
//            "prompt": editedPrompt,
//            "answers": FieldValue.delete()
//        ]) { error in
//            if let error = error {
//                print("Error updating prompt: \(error)")
//            } else {
//                // Successfully updated prompt
//                print("Prompt successfully updated")
//                self.devService.prompts[self.date]?.answers = nil
//                self.devService.prompts[self.date]?.prompt = editedPrompt
//            }
//        }
//    }
//}
//
//class DeveloperService: ObservableObject {
//    @Published var prompts: [String: FSPrompt] = [:]
//    private var listener: ListenerRegistration?
//    
//    init() {
//        if listener != nil {
//            return
//        }
//        listener = AppEngine.db.collection("prompts").addSnapshotListener { [weak self] snapshot, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Error fetching prompts: \(error)")
//                return
//            }
//            print("Found \(snapshot?.documents.count ?? 0) documents in the prompts collection")
//            self.prompts = Dictionary(uniqueKeysWithValues: snapshot?.documents.compactMap { document in
//                try? document.data(as: FSPrompt.self)
//            }.map { prompt in
//                (prompt.date, prompt) // Create a tuple with 'date' as the key and 'prompt' as the value
//            } ?? [])
//        }
//    }
//    
//    deinit {
//        listener?.remove()
//        listener = nil
//    }
//}
//
//struct FSPrompt: Identifiable, Codable, Hashable {
//    @DocumentID var id: String?
//    var date: String
//    var count: Int?
//    var prompt: String
//    var answers: [String]?
//}
