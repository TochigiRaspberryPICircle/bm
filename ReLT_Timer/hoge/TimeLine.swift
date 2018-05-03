//
//  TimeLine.swift
//  hoge
//
//  Created by akimach on 2018/05/01.
//  Copyright © 2018年 akimach. All rights reserved.
//

import Foundation

class TimeLine {
    var index = 0
    var timerSettings: [TimerSettings] = []
    
    func add(mode: TimerMode) {
        timerSettings.append((done: false, title: "notitle", minute: 1, second: 0))
    }
    
    func delete(mode: TimerMode, index: Int) {
        if index < 0 { return }
        timerSettings.remove(at: index)
    }
    
    func get(mode: TimerMode) -> [TimerSettings] {
        return self.timerSettings
    }
    
    func done(mode: TimerMode, index: Int) {
        timerSettings[index].done = true
    }
    
    func set(mode: TimerMode, index: Int, title: String) {
        timerSettings[index].title = title
    }
    
    func set(mode: TimerMode, index: Int, minute: Int) {
        timerSettings[index].minute = minute
    }
    
    func set(mode: TimerMode, index: Int, second: Int) {
        timerSettings[index].second = second
    }
    
    func reset(mode: TimerMode, index: Int) {
//        timerSettings[index].minute = 0
//        timerSettings[index].second = 0
    }
    
    func reset() {
        for i in (0 ..< timerSettings.count) {
            timerSettings[i].done = false
        }
    }
}
