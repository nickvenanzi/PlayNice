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
        
    @Published var prompt: Prompt
    
    init() {
        if let prompt = UserDefaults.standard.string(forKey: StorageKeys.PROMPT) {
            let submitted = UserDefaults.standard.bool(forKey: StorageKeys.PROMPT_SUBMITTED)
            self.prompt = Prompt(text: prompt, submitted: submitted)
            print("default found")
            return
        }
        print("No default Prompt storage")
        prompt = Prompt(text: "", submitted: false)
        retrievePrompt()
    }
    
    func retrievePrompt() {
        let today = TimeEngine.shared.today.toString()
        PromptEngine.db.collection("prompts").whereField("date", isEqualTo: today).getDocuments() { (querySnapshot, err) in
            if let _ = err {
                return
            }
            guard let document = querySnapshot!.documents.first else {
                return
            }
            let prompt = document.data()["prompt"] as! String
            UserDefaults.standard.set(prompt, forKey: StorageKeys.PROMPT)
            UserDefaults.standard.set(false, forKey: StorageKeys.PROMPT_SUBMITTED)
            self.prompt = Prompt(text: prompt, submitted: false)
            return
        }
    }
}
