//
//  UserEngine.swift
//  Kevin
//
//  Created by Nick Venanzi on 5/29/23.
//

import Foundation
import Firebase
import Combine

class AppEngine: ObservableObject {
    
    static var db: Firestore {
        Firestore.firestore()
    }
    
    var timer: AnyCancellable?
    var votedOn: Set<String> = Set()
    var answerQueue: Set<Answer> = Set()
    var lastNewDoc: DocumentSnapshot?
    var lastTopDoc: DocumentSnapshot?
    
    @Published var today: AnswerDate = AnswerDate()
    @Published var prompt: Prompt = Prompt(text: "Loading prompt...", submitted: true)
    @Published var currentAnswers: [Answer] = []
    @Published var selectedAnswer: Int?
    @Published var rankings: Set<Answer> = Set()
    @Published var following: Set<User> = Set()
    @Published var user: User = User()
    
    @Published var debugCounter: Int = 0
    
    init() {
        retrieveFromCache()
        initializeTimer()
    }
    
    deinit {
        timer?.cancel()
    }
    
    func initializeTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.debugCounter += 1
                if AnswerDate() != self?.today {
                    self?.debugCounter = 11123
                    self?.today = AnswerDate()
                    UserDefaults.standard.set(self?.today.toString(), forKey: StorageKeys.DATE)
                    self?.newDay()
                }
            }
    }
    
    /*
     Takes the appropriate actions following detection of a new day
     */
    func newDay() {
        votedOn = Set()
        answerQueue = Set()
        lastTopDoc = nil
        lastNewDoc = nil
        currentAnswers = []
        selectedAnswer = nil
        rankings = Set()
        
        UserDefaults.standard.set(nil, forKey: StorageKeys.LAST_TOP_DOC)
        UserDefaults.standard.set(nil, forKey: StorageKeys.LAST_NEW_DOC)
        UserDefaults.standard.set(nil, forKey: StorageKeys.ANSWER_QUEUE)
        UserDefaults.standard.set(nil, forKey: StorageKeys.PROMPT)
        UserDefaults.standard.set(false, forKey: StorageKeys.PROMPT_SUBMITTED)
        UserDefaults.standard.set(nil, forKey: StorageKeys.VOTED_ON)
        UserDefaults.standard.set(nil, forKey: StorageKeys.RANKINGS)
        
        retrievePrompt()
        getUserDocument {
            self.updateRankingsAndFollowing()
        }
        getAnswerSet()
        
    }
    
    /*
     Retrieves "users" document associated with the current user
     */
    func getUserDocument(_ completionHandler: @escaping () -> ()) {
        
        let userQuery = AppEngine.db.collection("users").whereField("id", isEqualTo: user.firebaseID).limit(to: 1)
        userQuery.getDocuments() { (qs, error) in
            guard let snapshot = qs else {
                self.setNewUserDocument {
                    completionHandler()
                }
                return
            }
            guard snapshot.documents.count > 0, let document = snapshot.documents.first else {
                self.setNewUserDocument {
                    completionHandler()
                }
                return
            }
            let docData = document.data()
            self.user.docID = document.documentID
            self.user.nickname = docData["username"] as? String ?? "Unknown User"
            let following = docData["following"] as? [String] ?? []
            self.user.following = Set(following)
            self.user.answers = self.processAnswersFromDoc(docData, document.documentID)
            self.user.orderAnswers()
            completionHandler()
            return
        }
    }
    
    private func setNewUserDocument(_ completionHandler: @escaping () -> ()) {
        var ref: DocumentReference? = nil
        ref = AppEngine.db.collection("users").addDocument(data: [
            "username": "",
            "id": user.firebaseID,
            "following": [],
        ]) { err in
            if let docID = ref?.documentID {
                self.user.docID = docID
            }
            completionHandler()
        }
    }
    
    /*
     Takes as input a "users" doc and processing the doc into answers
     */
    private func processAnswersFromDoc(_ doc: [String: Any]?, _ docID: String) -> [AnswerDate: Answer] {
        let result = doc?["answers"] as? [String: Any]
        let author = doc?["username"] as? String ?? "..."
        var answerMap: [AnswerDate: Answer] = [:]

        guard let answers = result else {
            return answerMap
        }
        for (dateStr, _map) in answers {
            guard let map = _map as? [AnyHashable: Any] else {
                continue
            }
            let date = AnswerDate.fromString(dateStr)
            let answerString = map["answer"] as? String ?? "..."
            let promptString = map["prompt"] as? String ?? "..."
            let winPercentage = map["winPercentage"] as? Float ?? 0.0
            let globalRank = map["globalRank"] as? Int
            let votes = map["votes"] as? Int ?? 0
            var answer = Answer(answer: answerString, prompt: promptString, author: author, authorDocID: docID, winPercentage: winPercentage, votes: votes, date: date)
            if globalRank != nil {
                answer.globalRank = globalRank
            }
            answerMap[date] = answer
        }
        return answerMap
    }
    
    func retrievePrompt() {
        print("Retrieving Prompt...")
        let today = AnswerDate().toString()
        AppEngine.db.collection("prompts").whereField("date", isEqualTo: today).getDocuments() { (querySnapshot, err) in
            if let _ = err { return }
            guard let document = querySnapshot!.documents.first else { return }
            let prompt = document.data()["prompt"] as! String
            UserDefaults.standard.set(prompt, forKey: StorageKeys.PROMPT)
            UserDefaults.standard.set(false, forKey: StorageKeys.PROMPT_SUBMITTED)
            self.prompt = Prompt(text: prompt, submitted: false)
            return
        }
    }
    
    func updateRankingsAndFollowing() {
        rankings = Set()
        following = Set()
        
        let yesterday = AnswerDate().dayBefore()
        
        retrieveTopAnswers(yesterday, 3)
        retrieveFollowing()
    }
    
    private func retrieveTopAnswers(_ date: AnswerDate, _ limit: Int) {
        let field = "answers." + date.toString() + ".globalRank"
        let topQuery = AppEngine.db.collection("users").order(by: field).limit(to: limit)
        topQuery.getDocuments() { (qs, error) in
            guard let snapshot = qs else {
                return
            }
            guard snapshot.documents.count > 0 else {
                return
            }
            for document in snapshot.documents {
                let answerMap: [AnswerDate: Answer] = self.processAnswersFromDoc(document.data(), document.documentID)
                guard let answer = answerMap[date] else {
                    continue
                }
                self.rankings.insert(answer)
            }
            print("Rankings count: \(self.rankings.count)")
            self.storeInCache()
            return
        }
    }

    func retrieveFollowing() {
        let yesterday = AnswerDate().dayBefore()

        if let selfAnswer = user.answers[yesterday] {
            rankings.insert(selfAnswer)
        }
        
        if user.following.isEmpty {
            return
        }
        
        for friend in user.following {
            let friendQuery = AppEngine.db.collection("users").document(friend)
            friendQuery.getDocument { (doc, error) in
                guard let document = doc, let docData = doc?.data() else {
                    return
                }
                var friend = User()
                friend.docID = document.documentID
                friend.nickname = docData["username"] as? String ?? "Unknown User"
                let friendFollowing = docData["following"] as? [String] ?? []
                friend.following = Set(friendFollowing)
                friend.answers = self.processAnswersFromDoc(docData, document.documentID)
                friend.orderAnswers()

                self.following.insert(friend)
                
                if let yesterdayAnswer = friend.answers[yesterday] {
                    self.rankings.insert(yesterdayAnswer)
                }
                self.storeInCache()
            }
        }
    }
    
    func updateNickname() {
        AppEngine.db.collection("users").document(user.docID).updateData([
            "username": user.nickname
        ]) { _ in }
    }
    
    /*
     Public facing method to submit user prompt to database
     */
    func submitAnswer(_ answer: String) {
        let date = AnswerDate()
        let answerKey = "answers."+date.toString()
        let userRef = AppEngine.db.collection("users").document(user.docID)
        userRef.updateData([
            answerKey: [
                "answer": answer,
                "prompt": prompt.text,
                "votes": 0,
                "winPercentage": 0.0,
                "time": FieldValue.serverTimestamp()
            ]
        ]) { _ in
            let answer = Answer(answer: answer, prompt: self.prompt.text, author: self.user.nickname, authorDocID: self.user.docID, winPercentage: 0, votes: 0, date: date)
            self.user.answers[date] = answer
            self.user.orderAnswers() // new answer wont be in ordered answers arrays until calling this
            UserDefaults.standard.set(true, forKey: StorageKeys.PROMPT_SUBMITTED)
            self.prompt.submitted = true
        }
    }
    

    /*
     Public facing method, tallies votes back into database.
     */
    func castVotes() {
        let winner = currentAnswers[selectedAnswer ?? 0]
        currentAnswers.forEach { answer in
            votedOn.insert(answer.authorDocID)
        }
        let date = AnswerDate().toString()
        let voteKey = "answers."+date+".votes"
        let winPercentKey = "answers."+date+".winPercentage"
        for answer in currentAnswers {
            let answerRef = AppEngine.db.collection("users").document(answer.authorDocID)
            AppEngine.db.runTransaction({ (transaction, errorPointer) -> Any? in
                let answerDoc: DocumentSnapshot
                do {
                    try answerDoc = transaction.getDocument(answerRef)
                } catch _ as NSError { return nil }
                guard let oldAnswers = answerDoc.data()?["answers"] as? [String: Any] else {
                    return nil
                }
                guard let oldAnswer = oldAnswers[date] as? [AnyHashable: Any] else {
                    return nil
                }
                guard let oldVotes = oldAnswer["votes"] as? Int, let oldWinPercentage = oldAnswer["winPercentage"] as? Double else {
                    return nil
                }
                let oldWins = Float(oldWinPercentage) * Float(oldVotes)
                let newVotes = oldVotes + 1
                let newWins = oldWins + (answer.authorDocID == winner.authorDocID ? 1 : 0)
                transaction.updateData([
                    voteKey: newVotes,
                    winPercentKey: newWins / Float(newVotes)
                ], forDocument: answerRef)
                return nil
            }) { _,_  in }
        }
    }
    
    /*
     Public facing method, inserts up to 4 answers as a list into currentAnswers.  If unable to provide at least 2 answers, currentAnswers remains empty.
     */
    func getAnswerSet() {
        print("getAnswerSet called")
        selectedAnswer = nil
        currentAnswers = []
        // if less than 2 answers, you need more answers to have a vote set
        if (answerQueue.count < 2) {
            retrieveMoreAnswers {
                // failed to retrieve enough answers
                if (self.answerQueue.count < 2) {
                    return
                }
                for _ in 1...4 {
                    if let answer = self.answerQueue.popFirst() {
                        self.currentAnswers.append(answer)
                    }
                }
            }
            return
        }
        for _ in 1...4 {
            if let answer = answerQueue.popFirst() {
                currentAnswers.append(answer)
            }
        }
    }

    /*
     Private helper method to retrieve more answers from the firestore database if possible.
     */
    private func retrieveMoreAnswers(_ completionHandler: @escaping () -> ()) {
        let dateStr = AnswerDate().toString()
        let group = DispatchGroup()
        group.enter()
        group.enter()

        // grab top answers
        var topQuery = AppEngine.db.collection("users").order(by: "answers."+dateStr+".winPercentage", descending: true).limit(to: 20)
        if let topDoc = lastTopDoc {
            topQuery = topQuery.start(afterDocument: topDoc)
        }
        queryAnswersAndAddToQueue(topQuery, true) {
            group.leave()
        }
        
        // grab newest answers
        let newQuery = AppEngine.db.collection("users").order(by: "answers."+dateStr+".votes").limit(to: 20)
        if let topDoc = lastNewDoc {
            topQuery = topQuery.start(afterDocument: topDoc)
        }
        queryAnswersAndAddToQueue(newQuery, false) {
            group.leave()
        }
        
        group.notify(queue: .main) {
            completionHandler()
        }
    }

    /*
     private helper to retrieveMoreAnswers()
     */
    private func queryAnswersAndAddToQueue(_ query: Query, _ isTopQuery: Bool, _ completionHandler: @escaping () -> ()) {
        query.getDocuments() { (qs, error) in
            guard let snapshot = qs else { completionHandler(); return }
            guard snapshot.documents.count > 0 else { completionHandler(); return }
            
            let date = AnswerDate()
            for document in snapshot.documents {
                let docID = document.documentID
                if (self.votedOn.contains(docID) || docID == self.user.docID) {
                    continue
                }
                let answers = document.data()["answers"] as! [String: Any]
                let a = answers[date.toString()] as! [AnyHashable: Any]
                let answerString = a["answer"] as? String ?? "Answer failed to load..."
                let promptString = a["prompt"] as? String ?? "Prompt failed to load..."
                let authorID = document.data()["id"] as? String ?? "Unknown User"
                let author = document.data()["username"] as? String ?? authorID
                let winPercentage = a["winPercentage"] as? Float ?? 0.0
                let votes = a["votes"] as? Int ?? 0
                let answer = Answer(answer: answerString, prompt: promptString, author: author, authorDocID: docID, winPercentage: winPercentage, votes: votes, date: date)
                if (self.answerQueue.contains(answer)) {
                    continue
                }
                self.answerQueue.insert(answer)
            }
            let lastDoc = snapshot.documents[snapshot.documents.count-1]
            if isTopQuery {
                self.lastTopDoc = lastDoc
            } else {
                self.lastNewDoc = lastDoc
            }
            completionHandler()
            return
        }
    }
    
    func storeInCache() {
        let ranksArray: [Answer] = Array(rankings)
        let followingArray: [User] = Array(following)
        let votedOnArray: [String] = Array(votedOn)
        let answerQueueArray: [Answer] = currentAnswers + Array(answerQueue)

        let encoder = JSONEncoder()

        let ranksData: [Data] = ranksArray.map { answer in
            return (try? encoder.encode(answer)) ?? Data()
        }
        let followingData: [Data] = followingArray.map { friend in
            return (try? encoder.encode(friend)) ?? Data()
        }
        let answersArray: [Data] = answerQueueArray.map { answer in
            return (try? encoder.encode(answer)) ?? Data()
        }
        
        UserDefaults.standard.set(today.toString(), forKey: StorageKeys.DATE)
        UserDefaults.standard.set(ranksData, forKey: StorageKeys.RANKINGS)
        UserDefaults.standard.set(followingData, forKey: StorageKeys.FOLLOWING)
        UserDefaults.standard.set(votedOnArray, forKey: StorageKeys.VOTED_ON)
        UserDefaults.standard.set(answersArray, forKey: StorageKeys.ANSWER_QUEUE)
        UserDefaults.standard.set(lastTopDoc?.documentID, forKey: StorageKeys.LAST_TOP_DOC)
        UserDefaults.standard.set(lastNewDoc?.documentID, forKey: StorageKeys.LAST_NEW_DOC)
    }

    func retrieveFromCache() {
        let decoder = JSONDecoder()
        
        if let todayStr = UserDefaults.standard.string(forKey: StorageKeys.DATE) {
            today = AnswerDate.fromString(todayStr)
        } else {
            debugCounter = -99999
            newDay()
        }
        
        if let promptStr = UserDefaults.standard.string(forKey: StorageKeys.PROMPT) {
            prompt.text = promptStr
            prompt.submitted = UserDefaults.standard.bool(forKey: StorageKeys.PROMPT_SUBMITTED)
        }

        if let ranksData = UserDefaults.standard.object(forKey: StorageKeys.RANKINGS) as? [Data] {
            rankings = Set()
            for data in ranksData {
                if let answer = try? decoder.decode(Answer.self, from: data) {
                    rankings.insert(answer)
                }
            }
        }
        if let followingData = UserDefaults.standard.object(forKey: StorageKeys.FOLLOWING) as? [Data] {
            following = Set()
            for data in followingData {
                if let friend = try? decoder.decode(User.self, from: data) {
                    following.insert(friend)
                }
            }
        }
        let votedOnArray = UserDefaults.standard.object(forKey: StorageKeys.VOTED_ON) as? [String] ?? []
        votedOn = Set(votedOnArray)

        let answerArray = UserDefaults.standard.object(forKey: StorageKeys.ANSWER_QUEUE) as? [Data] ?? []
        answerQueue = Set()
        for data in answerArray {
            if let answer = try? decoder.decode(Answer.self, from: data) {
                answerQueue.insert(answer)
            }
        }
        if let lastTopDocID = UserDefaults.standard.string(forKey: StorageKeys.LAST_TOP_DOC) {
            AppEngine.db.collection("users").document(lastTopDocID).getDocument { (document, error) in self.lastTopDoc = document }
        }
        if let lastNewDocID = UserDefaults.standard.string(forKey: StorageKeys.LAST_NEW_DOC) {
            AppEngine.db.collection("users").document(lastNewDocID).getDocument { (document, error) in self.lastNewDoc = document }
        }
    }
    
//    static func searchUsers(_ searchQuery: String, _ completionHandler: @escaping ([User]) -> ()) {
//        if db == nil {
//            db = Firestore.firestore()
//        }
//        let appendage = "🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼🇿🇼"
//        let userQuery = self.db.collection("users").whereField("username", isGreaterThanOrEqualTo: searchQuery).whereField("username", isLessThanOrEqualTo: searchQuery + appendage).limit(to: 10)
//        userQuery.getDocuments() { (qs, error) in
//            guard let snapshot = qs else {
//                print("no snapshot")
//                completionHandler([])
//                return
//            }
//            guard snapshot.documents.count > 0 else {
//                print("no results returned")
//                completionHandler([])
//                return
//            }
//            var results: [User] = []
//            for document in snapshot.documents {
//                let docData = document.data()
//                var resultUser = User()
//                resultUser.docID = document.documentID
//                if resultUser.docID == user.docID {
//                    // can't follow self
//                    continue
//                }
//                resultUser.nickname = docData["username"] as? String ?? "Unknown User"
//                let following = docData["following"] as? [String] ?? []
//                resultUser.following = Set(following)
//                resultUser.answers = processAnswersFromDoc(docData, document.documentID)
//                resultUser.orderAnswers()
//                results.append(resultUser)
//            }
//            completionHandler(results)
//            return
//        }
//    }
//    
//    static func followUser(_ otherUser: User) {
//        user.following.insert(otherUser.docID)
//        if following == nil {
//            following = Set()
//        }
//        following!.insert(otherUser)
//        if rankings != nil, let previousAnswer = otherUser.answers[PromptEngine.getPreviousDate()] {
//            rankings!.insert(previousAnswer)
//        }
//        db.collection("users").document(user.docID).updateData([
//            "following": Array(user.following)
//        ]) { _ in }
//    }
//    
//    static func unfollowUser(_ otherUser: User) {
//        user.following.remove(otherUser.docID)
//        following?.remove(otherUser)
//        if rankings != nil, let previousAnswer = otherUser.answers[PromptEngine.getPreviousDate()] {
//            rankings!.remove(previousAnswer)
//        }
//        db.collection("users").document(user.docID).updateData([
//            "following": Array(user.following)
//        ]) { _ in }
//    }

}
