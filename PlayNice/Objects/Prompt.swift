//
//  Prompt.swift
//  PlayNice
//
//  Created by Nick Venanzi on 8/2/24.
//

import Foundation

class Prompt: ObservableObject {
    @Published var text: String = ""
    @Published var date: AnswerDate
    
    init(_ text: String, _ date: AnswerDate) {
        self.text = text
        self.date = date
    }
}
