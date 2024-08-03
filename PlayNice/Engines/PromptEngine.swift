//
//  PromptEngine.swift
//  Kevin
//
//  Created by Nick Venanzi on 5/15/23.
//

import Foundation
import Firebase

class PromptEngine {

    static var db: Firestore {
        Firestore.firestore()
    }
    
    static var shared: PromptEngine = PromptEngine()
    
    /*
     Public facing method to submit user prompt to database.  Upon completion, handler is called to take app to VoteVC
     */
    static func submitPrompt(_ prompt: String, _ answer: String, _ completionHandler: @escaping () -> ()) {

        let date = getDate()
        let answerKey = "answers."+date
        let userRef = db.collection("users").document(UserEngine.user.docID)
        userRef.updateData([
            answerKey: [
                "answer": answer,
                "prompt": prompt,
                "votes": 0,
                "winPercentage": 0.0,
                "time": FieldValue.serverTimestamp()
            ]
        ]) { _ in
            completionHandler()
        }
    }
    
    static func isNewDay() -> Bool {
        let today = getDate()
        let lastDate = UserDefaults.standard.string(forKey: "date")
        if (today == lastDate) {
            return false
        } else {
            return true
        }
    }
    
    static func retrievePrompt(_ completionHandler: @escaping (String?) -> ()) {
        let today = getDate()
        self.db.collection("prompts").whereField("date", isEqualTo: today).getDocuments() { (querySnapshot, err) in
            if let _ = err {
                completionHandler(nil)
                return
            }
            guard let document = querySnapshot!.documents.first else {
                completionHandler(nil)
                return
            }
            let prompt = document.data()["prompt"] as! String
            UserDefaults.standard.set(prompt, forKey: StorageKeys.PROMPT)
            UserDefaults.standard.set(false, forKey: StorageKeys.PROMPT_SUBMITTED)
            UserDefaults.standard.set(today, forKey: StorageKeys.DATE)
            completionHandler(prompt)
            return
        }
    }
    
    static func getDate() -> String {
        let pieces = Date().description.split(separator: " ")[0].split(separator: "-")
        let year = Int(String(pieces[0])) ?? 0
        let month = Int(String(pieces[1])) ?? 0
        let day = Int(String(pieces[2])) ?? 0
        return "\(year)-\(month)-\(day)"
    }
    
    static func getPreviousDate() -> String {
        let thirtyOne: Set<Int> = Set([1,3,5,7,8,10,12])
        let thirty: Set<Int> = Set([4,6,9,11])
        let today = getDate()
        let pieces: [Int] = today.split(separator: "-").map { str in
            Int(str) ?? 1
        }
        var day = pieces[2] - 1
        var month = pieces[1]
        var year = pieces[0]
        if day == 0 {
            month -= 1
            if month == 0 {
                month = 12
                year -= 1
            }
            if (thirtyOne.contains(month)) {
                day = 31
            } else if (thirty.contains(month)) {
                day = 30
            } else if (year % 4 == 0) {
                day = 29
            } else {
                day = 28
            }
        }
        return "\(year)-\(month)-\(day)"
    }
}
