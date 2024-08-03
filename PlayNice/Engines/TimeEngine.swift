//
//  TimeEngine.swift
//  PlayNice
//
//  Created by Nick Venanzi on 8/3/24.
//

import SwiftUI
import Combine

class TimeEngine: ObservableObject {
    
    private var timer: AnyCancellable?
    
    @Published var today: AnswerDate = AnswerDate()
    @Published var yesterday: AnswerDate = AnswerDate.yesterday()
    
    static var shared: TimeEngine = TimeEngine()
        
    init() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                if AnswerDate() != self?.today {
                    self?.yesterday = AnswerDate.yesterday()
                    self?.today = AnswerDate()
                }
            }
    }
    
    deinit {
        timer?.cancel()
    }
}
