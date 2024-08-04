////
////  AnswerEngine.swift
////  Kevin
////
////  Created by Nick Venanzi on 5/28/23.
////
//import Firebase
//import FirebaseFirestore
//
//class AnswerEngine {
//    static var ref: DatabaseReference!
//    static var db: Firestore!
//    
//    static var votedOn: Set<String> = Set()
//    static var currentAnswers: [Answer] = []
//    static var answerQueue: Set<Answer> = Set()
//    static var lastDocID: String?
//    static var selectedAnswer: Int?
//    
//    /*
//     Public facing method, tallies votes back into database.
//     */
//    static func castVotes(_ winner: Answer) {
//        if db == nil {
//            db = Firestore.firestore()
//        }
//        let previousAnswers = Array(currentAnswers)
//        previousAnswers.forEach { answer in
//            votedOn.insert(answer.authorDocID)
//        }
//        let date = PromptEngine.getDate()
//        let voteKey = "answers."+date+".votes"
//        let winPercentKey = "answers."+date+".winPercentage"
//        for answer in previousAnswers {
//            let answerRef = db.collection("users").document(answer.authorDocID)
//            db.runTransaction({ (transaction, errorPointer) -> Any? in
//                let answerDoc: DocumentSnapshot
//                do {
//                    try answerDoc = transaction.getDocument(answerRef)
//                } catch _ as NSError { return nil }
//                guard let oldAnswers = answerDoc.data()?["answers"] as? [String: Any] else {
//                    return nil
//                }
//                guard let oldAnswer = oldAnswers[date] as? [AnyHashable: Any] else {
//                    return nil
//                }
//                guard let oldVotes = oldAnswer["votes"] as? Int, let oldWinPercentage = oldAnswer["winPercentage"] as? Double else {
//                    return nil
//                }
//                let oldWins = Float(oldWinPercentage) * Float(oldVotes)
//                let newVotes = oldVotes + 1
//                let newWins = oldWins + (answer.authorDocID == winner.authorDocID ? 1 : 0)
//                transaction.updateData([
//                    voteKey: newVotes,
//                    winPercentKey: newWins / Float(newVotes)
//                ], forDocument: answerRef)
//                return nil
//            }) { _,_  in }
//        }
//    }
//    
//    /*
//     Public facing method, inserts up to 4 answers as a list into the
//     input completionHandler.  If unable to provide at least 2 answers, returns
//     empty array.
//     */
//    static func getAnswerSet(_ completionHandler: @escaping () -> ()) {
//        // if less than 2 answers, you need more answers to have a vote set
//        if (answerQueue.count < 2) {
//            print("Less than 2 answers in the answerQueue (\(answerQueue.count)), retrieving more...")
//            retrieveMoreAnswers {
//                selectedAnswer = nil
//                currentAnswers = []
//                // failed to retrieve enough answers
//                if (answerQueue.count < 2) {
//                    print("Failed to retrieve enough answers (\(answerQueue.count) in queue), returning...")
//                    completionHandler()
//                    return
//                }
//                for _ in 1...4 {
//                    if let answer = answerQueue.popFirst() {
//                        currentAnswers.append(answer)
//                    }
//                }
//                completionHandler()
//                return
//            }
//            return
//        }
//        selectedAnswer = nil
//        currentAnswers = []
//        for _ in 1...4 {
//            if let answer = answerQueue.popFirst() {
//                currentAnswers.append(answer)
//            }
//        }
//        completionHandler()
//        return
//    }
//    
//    /*
//     Store away votedOn and queue of answers if user leaves app
//     */
//    static func storeAnswersInCache() {
//        let encoder = JSONEncoder()
//
//        let votedOnArray: [String] = Array(votedOn)
//        var queueArray: [Answer] = currentAnswers
//        queueArray += Array(answerQueue)
//        let storageArray: [Data] = queueArray.map { answer in
//            if let encoded = try? encoder.encode(answer) {
//                return encoded
//            } else {
//                print("Error encoding answer")
//                return Data()
//            }
//        }
//        UserDefaults.standard.set(votedOnArray, forKey: "votedOn")
//        UserDefaults.standard.set(storageArray, forKey: "answerQueue")
//        UserDefaults.standard.set(lastDocID, forKey: "lastDocID")
//    }
//    
//    /*
//     Retrieve votedOn and queue of answers if user returns from app
//     */
//    static func retrieveFromCache(_ completionHandler: @escaping () -> ()) {
//        let decoder = JSONDecoder()
//        let votedOnArray = UserDefaults.standard.object(forKey: "votedOn") as? [String] ?? []
//        let dataArray = UserDefaults.standard.object(forKey: "answerQueue") as? [Data] ?? []
//        answerQueue = Set()
//        for data in dataArray {
//            if let answer = try? decoder.decode(Answer.self, from: data) {
//                answerQueue.insert(answer)
//            } else {
//                print("Error decoding answer")
//            }
//        }
//        print("Voted on \(votedOnArray.count) answers already")
//        print("Still have \(answerQueue.count) answers ready to vote on")
//        lastDocID = UserDefaults.standard.string(forKey: "lastDocID")
//        votedOn = Set(votedOnArray)
//        completionHandler()
//    }
//    
//    /*
//     Reset data on new day
//     */
//    static func reset() {
//        votedOn = Set()
//        answerQueue = Set()
//        lastDocID = nil
//        currentAnswers = []
//        selectedAnswer = nil
//        UserDefaults.standard.set(nil, forKey: "votedOn")
//        UserDefaults.standard.set(nil, forKey: "answerQueue")
//        UserDefaults.standard.set(nil, forKey: "lastDocID")
//    }
//    
//    /*
//     Private helper method to retrieve more answers from the firestore database if possible.
//     */
//    static private func retrieveMoreAnswers(_ completionHandler: @escaping () -> ()) {
//        retrieveAnswerPoolSizeAndDate { s, d in
//            guard let size = s, let date = d else {
//                /*
//                 TO-DO pop up alert for failure to retrieve data?
//                 */
//                completionHandler()
//                return
//            }
//            print("# of answers in database: \(size), for date: \(date)")
//            if (size > 100) {
//                /*
//                 Below is for grabbing select number of docs from larger pool of answers (>100)
//                 */
//                // first grab newest
//                let topQuery = self.db.collection("users").order(by: "answers."+date+".winPercentage", descending: true).limit(to: 20)
//                queryAnswersAndAddToQueue(topQuery, date) {
//                    let newQuery = self.db.collection("users").order(by: "answers."+date+".votes").limit(to: 20)
//                    queryAnswersAndAddToQueue(newQuery, date, completionHandler)
//                }
//            } else {
//                /*
//                 Below is for grabbing entire database, since size is less than 100
//                 */
//                var query = self.db.collection("users").order(by: "answers."+date+".time")
//                //pick up where last left off if not first query of day
//                if lastDocID != nil {
//                    print("Starting after document: \(lastDocID!)")
//                    db.collection("users").document(lastDocID!).getDocument { (document, error) in
//                        guard let document = document, document.exists else {
//                            print("Error XYZ")
//                            return
//                        }
//                        query = query.start(afterDocument: document)
//                        query.limit(to: 40)
//                        queryAnswersAndAddToQueue(query, date, completionHandler)
//                    }
//                    return
//                }
//                query.limit(to: 40)
//                queryAnswersAndAddToQueue(query, date, completionHandler)
//            }
//            
//        }
//    }
//    
//    /*
//     private helper to retrieveMoreAnswers()
//     */
//    static private func queryAnswersAndAddToQueue(_ query: Query, _ date: String, _ completionHandler: @escaping () -> ()) {
//        query.getDocuments() { (qs, error) in
//            guard let snapshot = qs else {
//                print("No snapshot returned")
//                completionHandler()
//                return
//            }
//            guard snapshot.documents.count > 0 else {
//                print("0 documents returned")
//                completionHandler()
//                return
//            }
//            for document in snapshot.documents {
//                let docID = document.documentID
//                if (votedOn.contains(docID)) {
//                    print("Already voted on answer")
//                    continue
//                }
//                let answers = document.data()["answers"] as! [String: Any]
//                let a = answers[date] as! [AnyHashable: Any]
//                let answerString = a["answer"] as? String ?? "Answer failed to load..."
//                let promptString = a["prompt"] as? String ?? "Prompt failed to load..."
//                let authorID = document.data()["id"] as? String ?? "Unknown User"
//                let author = document.data()["username"] as? String ?? authorID
//                let winPercentage = a["winPercentage"] as? Float ?? 0.0
//                let votes = a["votes"] as? Int ?? 0
//                let answer = Answer(answer: answerString, prompt: promptString, author: author, authorDocID: docID, winPercentage: winPercentage, votes: votes, date: date)
//                if (answerQueue.contains(answer)) {
//                    print("Answer already in answer queue")
//                    continue
//                }
//                if (answer.authorDocID == UserEngine.user.docID) {
//                    print("This is my answer")
//                    continue
//                }
//                AnswerEngine.answerQueue.insert(answer)
//            }
//            lastDocID = snapshot.documents[snapshot.documents.count-1].documentID
//            completionHandler()
//            return
//        }
//    }
//    
//    /*
//     Private helper for retrieveMoreAnswers()
//     */
//    static private func retrieveAnswerPoolSizeAndDate(_ completionHandler: @escaping (Int?, String?) -> ()) {
//        if ref == nil {
//            ref = Database.database().reference()
//        }
//        if db == nil {
//            db = Firestore.firestore()
//        }
//        // first check estimate of # of answers
//        let date = PromptEngine.getDate()
//        ref.child("answerCount").getData(completion:  { error, snapshot in
//            let rom = snapshot?.value as? Int
//            completionHandler(rom, date)
//        });
//    }
//}
