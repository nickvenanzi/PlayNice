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
    
    static var shared: TimeEngine = TimeEngine()
        
    init() {
        let lastDate = UserDefaults.standard.string(forKey: StorageKeys.DATE)
        if let todayStr = lastDate {
            today = AnswerDate.fromString(todayStr)
        }
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                if AnswerDate() != self?.today {
                    self?.today = AnswerDate()
                    UserDefaults.standard.set(self?.today.toString(), forKey: StorageKeys.DATE)
                }
            }
    }
    
    deinit {
        timer?.cancel()
    }
}
