//
//  PromptEngine.swift
//  Kevin
//
//  Created by Nick Venanzi on 5/15/23.
//

import Foundation
import Firebase
import SwiftUI

class PromptEngine: ObservableObject {

    static var db: Firestore {
        Firestore.firestore()
    }
    
    static var shared: PromptEngine = PromptEngine()
    
    @Published var prompt: Prompt
    
    init() {
        if let prompt = UserDefaults.standard.string(forKey: StorageKeys.PROMPT) {
            let submitted = UserDefaults.standard.bool(forKey: StorageKeys.PROMPT_SUBMITTED)
            self.prompt = Prompt(text: prompt, submitted: submitted)
            return
        }
        self.prompt = Prompt(text: "", submitted: false)
        PromptEngine.retrievePrompt()
    }
    
    /*
     Public facing method to submit user prompt to database.  Upon completion, handler is called to take app to VoteVC
     */
    static func submitPrompt(_ prompt: String, _ answer: String, _ completionHandler: @escaping () -> ()) {
        let date = TimeEngine.shared.today.toString()
        let answerKey = "answers."+date
        let userRef = db.collection("users").document(UserEngine.shared.user.docID)
        userRef.updateData([
            answerKey: [
                "answer": answer,
                "prompt": prompt,
                "votes": 0,
                "winPercentage": 0.0,
                "time": FieldValue.serverTimestamp()
            ]
        ]) { _ in
            PromptEngine.shared.prompt.submitted = true
            UserDefaults.standard.set(true, forKey: StorageKeys.PROMPT_SUBMITTED)
            completionHandler()
        }
    }
    
    static func retrievePrompt() {
        let today = TimeEngine.shared.today.toString()
        self.db.collection("prompts").whereField("date", isEqualTo: today).getDocuments() { (querySnapshot, err) in
            if let _ = err {
                return
            }
            guard let document = querySnapshot!.documents.first else {
                return
            }
            let prompt = document.data()["prompt"] as! String
            UserDefaults.standard.set(prompt, forKey: StorageKeys.PROMPT)
            UserDefaults.standard.set(false, forKey: StorageKeys.PROMPT_SUBMITTED)
            PromptEngine.shared.prompt = Prompt(text: prompt, submitted: false)
            return
        }
    }
}
