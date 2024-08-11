//
//  UserEngine.swift
//  Kevin
//
//  Created by Nick Venanzi on 5/29/23.
//

import Foundation
import Firebase

class UserEngine: ObservableObject {
    
    static var db: Firestore {
        Firestore.firestore()
    }
    
    @Published var rankings: Set<Answer> = Set()
    @Published var following: Set<User> = Set()
    @Published var user: User = User()
    
    init() {
        retrieveFromCache()
    }
    
    /*
     Retrieves "users" document associated with the current user
     */
    func getUserDocument() {
        
        let userQuery = UserEngine.db.collection("users").whereField("id", isEqualTo: user.firebaseID).limit(to: 1)
        userQuery.getDocuments() { (qs, error) in
            guard let snapshot = qs else {
                self.setNewUserDocument()
                return
            }
            guard snapshot.documents.count > 0, let document = snapshot.documents.first else {
                self.setNewUserDocument()
                return
            }
            let docData = document.data()
            self.user.docID = document.documentID
            self.user.nickname = docData["username"] as? String ?? "Unknown User"
            let following = docData["following"] as? [String] ?? []
            self.user.following = Set(following)
            self.user.answers = self.processAnswersFromDoc(docData, document.documentID)
            self.user.orderAnswers()
            return
        }
    }
    
    private func setNewUserDocument() {
        var ref: DocumentReference? = nil
        ref = UserEngine.db.collection("users").addDocument(data: [
            "username": "",
            "id": user.firebaseID,
            "following": [],
        ]) { err in
            if let docID = ref?.documentID {
                self.user.docID = docID
            }
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
    
    func updateRankingsAndFollowing() {
        rankings = Set()
        following = Set()
        
        let yesterday = TimeEngine.shared.today.dayBefore()
        
        retrieveTopAnswers(yesterday, 3)
        retrieveFollowing()
    }
    
    private func retrieveTopAnswers(_ date: AnswerDate, _ limit: Int) {
        let field = "answers." + date.toString() + ".globalRank"
        let topQuery = UserEngine.db.collection("users").order(by: field).limit(to: limit)
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
            self.storeInCache()
            return
        }
    }

    func retrieveFollowing() {
        let yesterday = TimeEngine.shared.today.dayBefore()

        if user.following.isEmpty {
            return
        }

        if let selfAnswer = user.answers[yesterday] {
            rankings.insert(selfAnswer)
        }
        
        for friend in user.following {
            let friendQuery = UserEngine.db.collection("users").document(friend)
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

    func storeInCache() {
        let ranksArray: [Answer] = Array(rankings)
        let followingArray: [User] = Array(following)
        let encoder = JSONEncoder()

        let ranksData: [Data] = ranksArray.map { answer in
            if let encoded = try? encoder.encode(answer) {
                return encoded
            } else {
                return Data()
            }
        }
        let followingData: [Data] = followingArray.map { friend in
            if let encoded = try? encoder.encode(friend) {
                return encoded
            } else {
                return Data()
            }
        }
        UserDefaults.standard.set(ranksData, forKey: StorageKeys.RANKINGS)
        UserDefaults.standard.set(followingData, forKey: StorageKeys.FOLLOWING)
    }

    func retrieveFromCache() {
        let decoder = JSONDecoder()

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
    }
    
    func updateNickname() {
        UserEngine.db.collection("users").document(user.docID).updateData([
            "username": user.nickname
        ]) { _ in }
    }
    
    /*
     Public facing method to submit user prompt to database
     */
    func submitPrompt(_ prompt: String, _ answer: String, _ completionHandler: @escaping () -> ()) {
        let date = TimeEngine.shared.today
        let answerKey = "answers."+date.toString()
        let userRef = UserEngine.db.collection("users").document(user.docID)
        userRef.updateData([
            answerKey: [
                "answer": answer,
                "prompt": prompt,
                "votes": 0,
                "winPercentage": 0.0,
                "time": FieldValue.serverTimestamp()
            ]
        ]) { _ in
            var answer = Answer(answer: answer, prompt: prompt, author: self.user.nickname, authorDocID: self.user.docID, winPercentage: 0, votes: 0, date: date)
            self.user.answers[date] = answer
            UserDefaults.standard.set(true, forKey: StorageKeys.PROMPT_SUBMITTED)
            completionHandler()
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
