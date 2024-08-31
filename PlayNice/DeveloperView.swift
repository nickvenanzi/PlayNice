import SwiftUI
import FirebaseFirestore
import FirebaseMessaging

struct DeveloperView: View {
    @State private var pickerValue = 0
    @EnvironmentObject var appEngine: AppEngine
    @StateObject private var devService: DeveloperService = DeveloperService()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 20) {
                    Button(action: {
                        if pickerValue == 0 { // prompts
                            devService.addPrompt()
                        } else { // users
                            devService.addUser()
                        }
                    }) {
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: 50)
                    .padding(.leading, 16)
                    
                    Picker("", selection: $pickerValue) {
                        Text("Prompts").tag(0)
                        Text("Users").tag(1)
                    }.pickerStyle(.segmented)
                }
    
                ScrollView {
                    LazyVGrid(columns: [GridItem(.fixed(50)), GridItem(.flexible())], spacing: 20) {
                        if pickerValue == 0 { // prompts
                            ForEach(devService.prompts.values.sorted {
                                AnswerDate.fromString($0.date) > AnswerDate.fromString($1.date)
                            }, id: \.self) { fsPrompt in
                                DateView(AnswerDate.fromString(fsPrompt.date))
                                    
                                NavigationLink(destination: DeveloperPromptView(date: fsPrompt.date).environmentObject(devService)) {
                                    Text(fsPrompt.prompt)
                                }
                            }
                        } else { // users
                            ForEach(devService.users.indices, id: \.self) { index in
                                Text("\(index + 1).")
                                let user = devService.users[index]
                                NavigationLink(destination: ProfileView(user)) {
                                    VStack {
                                        HStack(spacing: 5) {
                                            Text(user.nickname)
                                            Spacer()
                                            let medals: String = user.getMedals()
                                            if (!medals.isEmpty) {
                                                Text(medals)
                                            }
                                        }
                                        
                                        let answer = Answer(answer: "", prompt: "", author: "", authorDocID: "", winPercentage: user.getAverage(), votes: user.getTotalWins(), date: AnswerDate())
                                        AnswerPercentageBar(answer, "wins")
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
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
                self.devService.prompts[self.date]?.answers = nil
                self.devService.prompts[self.date]?.prompt = editedPrompt
            }
        }
    }
}

class DeveloperService: ObservableObject {
    @Published var prompts: [String: FSPrompt] = [:]
    @Published var users: [User] = []
    private var promptListener: ListenerRegistration?

    init() {
        if promptListener == nil {
            promptListener = AppEngine.db.collection("prompts").addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let _ = error {
                    return
                }
                self.prompts = Dictionary(uniqueKeysWithValues: snapshot?.documents.compactMap { document in
                    try? document.data(as: FSPrompt.self)
                }.map { prompt in (prompt.date, prompt) } ?? [])
            }
        }
        
        if users.isEmpty {
            AppEngine.db.collection("users").whereField("bot", isEqualTo: true).getDocuments { s, _ in
                guard let snapshot = s else { return }
                for userDoc in snapshot.documents {
                    var user = User()
                    let docData = userDoc.data()
                    user.docID = userDoc.documentID
                    user.nickname = docData["username"] as? String ?? "Unknown User"
                    user.answers = AppEngine.processAnswersFromDoc(docData, userDoc.documentID)
                    user.orderAnswers()
                    self.users.append(user)
                }
            }
        }
    }
    
    deinit {
        promptListener?.remove()
        promptListener = nil
    }
    
    func addPrompt() {
        let max = prompts.max { pair1, pair2 in
            AnswerDate.fromString(pair1.key) < AnswerDate.fromString(pair2.key)
        }
        var maxDay = AnswerDate.fromString(max?.value.date ?? AnswerDate().toString())
        if maxDay < AnswerDate() {
            maxDay = AnswerDate()
        }
        let nextDay = maxDay.dayAfter().toString()
        let prompt = FSPrompt(date: nextDay, prompt: "Type in a prompt")
        prompts[nextDay] = prompt
        
        AppEngine.db.collection("prompts").addDocument(data: [
            "date": prompt.date,
            "prompt": prompt.prompt,
            "answers": [""],
        ])
    }
    
    func addUser() {
        var user = User()
        user.nickname = "anonymous"
        
        var ref: DocumentReference? = nil
        ref = AppEngine.db.collection("users").addDocument(data: [
            "username": user.nickname,
            "id": "",
            "following": [],
            "bot": true
        ]) { err in
            if let docID = ref?.documentID {
                user.docID = docID
                self.users.insert(user, at: 0)
            }
        }
    }
}

struct FSPrompt: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var date: String
    var prompt: String
    var answers: [String]?
}
