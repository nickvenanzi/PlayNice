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
    static var shared: UserEngine {
        UserEngine()
    }
    
    @Published var rankings: Set<Answer>?
    @Published var following: Set<User>?
    @Published var user: User = User()
    
    /*
     Retrieves "users" document associated with the current user
     */
    static func getUserDocument() {
        
        let userQuery = self.db.collection("users").whereField("id", isEqualTo: shared.user.firebaseID).limit(to: 1)
        userQuery.getDocuments() { (qs, error) in
            guard let snapshot = qs else {
                return
            }
            guard snapshot.documents.count > 0 else {
                setNewUserDocument()
                return
            }
            for document in snapshot.documents {
                let docData = document.data()
                shared.user.docID = document.documentID
                shared.user.nickname = docData["username"] as? String ?? "Unknown User"
                let following = docData["following"] as? [String] ?? []
                shared.user.following = Set(following)
                shared.user.answers = processAnswersFromDoc(docData, document.documentID)
                shared.user.orderAnswers()
                break
            }
            return
        }
    }
    
    static private func setNewUserDocument() {
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "username": "",
            "id": shared.user.firebaseID,
            "following": [],
        ]) { err in
            if let docID = ref?.documentID {
                UserEngine.shared.user.docID = docID
            }
        }
    }
    
    /*
     Takes as input a "users" doc and processing the doc into answers
     */
    static private func processAnswersFromDoc(_ doc: [String: Any]?, _ docID: String) -> [AnswerDate: Answer] {
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
//    static func updateRankingsAndFollowing(_ completionHandler: @escaping () -> ()) {
//        if rankings != nil && following != nil {
//            completionHandler()
//            return
//        }
//        rankings = nil
//        
//        let yesterday = PromptEngine.getPreviousDate()
//        let group = DispatchGroup()
//        group.enter()
//        group.enter()
//        
//        UserEngine.retrieveTopAnswers(yesterday, 3) {
//            print("Top answers returned")
//            group.leave()
//        }
//        
//        UserEngine.retrieveFollowing {
//            for otherUser in following ?? Set() {
//                guard let answer = otherUser.answers[yesterday] else {
//                    continue
//                }
//                if rankings == nil {
//                    rankings = Set()
//                }
//                rankings!.insert(answer)
//            }
//            // add user's answer from yesterday:
//            if let selfAnswer = UserEngine.user.answers[yesterday] {
//                if rankings == nil {
//                    rankings = Set()
//                }
//                rankings!.insert(selfAnswer)
//            }
//            group.leave()
//        }
//        
//        group.notify(queue: .main) {
//            completionHandler()
//        }
//        
//    }
//    
//    static private func retrieveTopAnswers(_ date: String, _ limit: Int, _ completionHandler: @escaping () -> ()) {
//        if db == nil {
//            db = Firestore.firestore()
//        }
//        let field = "answers." + date + ".globalRank"
//        let topQuery = self.db.collection("users").order(by: field).limit(to: limit)
//        topQuery.getDocuments() { (qs, error) in
//            guard let snapshot = qs else {
//                completionHandler()
//                return
//            }
//            guard snapshot.documents.count > 0 else {
//                completionHandler()
//                return
//            }
//            for document in snapshot.documents {
//                let answerMap: [String: Answer] = processAnswersFromDoc(document.data(), document.documentID)
//                guard let answer = answerMap[date] else {
//                    continue
//                }
//                if rankings == nil {
//                    rankings = Set()
//                }
//                rankings!.insert(answer)
//            }
//            completionHandler()
//            return
//        }
//    }
//    
//    static func retrieveFollowing(_ completionHandler: @escaping () -> ()) {
//        if db == nil {
//            db = Firestore.firestore()
//        }
//        if user.following.isEmpty || following != nil {
//            completionHandler()
//            return
//        }
//        let group = DispatchGroup()
//        
//        for _ in user.following {
//            group.enter()
//        }
//        for friend in user.following {
//            let friendQuery = self.db.collection("users").document(friend)
//            friendQuery.getDocument { (doc, error) in
//                guard let document = doc, let docData = doc?.data() else {
//                    group.leave()
//                    return
//                }
//                var friend = User()
//                friend.docID = document.documentID
//                friend.nickname = docData["username"] as? String ?? "Unknown User"
//                let friendFollowing = docData["following"] as? [String] ?? []
//                friend.following = Set(friendFollowing)
//                friend.answers = processAnswersFromDoc(docData, document.documentID)
//                friend.orderAnswers()
//                
//                if following == nil {
//                    following = Set()
//                }
//                following!.insert(friend)
//                group.leave()
//                return
//            }
//        }
//        group.notify(queue: .main) {
//            completionHandler()
//        }
//    }
//    
//    /*
//     Reset data on new day
//     */
//    static func reset() {
//        following = nil
//        rankings = nil
//        UserDefaults.standard.set(nil, forKey: "rankings")
//        UserDefaults.standard.set(nil, forKey: "following")
//    }
//    
//    static func storeInCache() {
//        let ranksArray: [Answer] = Array(rankings ?? Set())
//        let followingArray: [User] = Array(following ?? Set())
//        let encoder = JSONEncoder()
//
//        let ranksData: [Data] = ranksArray.map { answer in
//            if let encoded = try? encoder.encode(answer) {
//                return encoded
//            } else {
//                print("Error encoding answer")
//                return Data()
//            }
//        }
//        let followingData: [Data] = followingArray.map { friend in
//            if let encoded = try? encoder.encode(friend) {
//                return encoded
//            } else {
//                print("Error encoding Friend")
//                return Data()
//            }
//        }
//        UserDefaults.standard.set(ranksData, forKey: "rankings")
//        UserDefaults.standard.set(followingData, forKey: "following")
//    }
//    
//    static func retrieveFromCache(_ completionHandler: @escaping () -> ()) {
//        let decoder = JSONDecoder()
//        
//        if let ranksData = UserDefaults.standard.object(forKey: "rankings") as? [Data] {
//            rankings = Set()
//            for data in ranksData {
//                if let answer = try? decoder.decode(Answer.self, from: data) {
//                    rankings!.insert(answer)
//                } else {
//                    print("Error decoding answer")
//                }
//            }
//        }
//        if let followingData = UserDefaults.standard.object(forKey: "following") as? [Data] {
//            following = Set()
//            for data in followingData {
//                if let friend = try? decoder.decode(User.self, from: data) {
//                    following!.insert(friend)
//                } else {
//                    print("Error decoding friend")
//                }
//            }
//        }
//        completionHandler()
//    }
    
//    static func updateNickname(_ nickname: String) {
//        // To update age and favorite color:
//        db.collection("users").document(user.docID).updateData([
//            "username": nickname
//        ]) { _ in }
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
