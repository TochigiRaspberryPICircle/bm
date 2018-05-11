//
//  TimeLine.swift
//  hoge
//
//  Created by akimach on 2018/05/01.
//  Copyright © 2018年 akimach. All rights reserved.
//

import Foundation

class TimeLine {
    var index = -1
    var timerSettings: [TimerSettings] = []
    
    
    func title() -> String {
        if index < 0 { return ""}
        return timerSettings[index].title
    }
    
    func minute() -> Int {
        if index < 0 { return 1}
        return timerSettings[index].minute
    }
    
    func second() -> Int {
        if index < 0 { return 0 }
        return timerSettings[index].second
    }
    
    func next() {
        self.index += 1
    }
    
    func add(mode: TimerMode) {
        timerSettings.append((done: false, title: "notitle", minute: 1, second: 0))
    }
    
    func add() {
        timerSettings.append((done: false, title: "notitle", minute: 1, second: 0))
    }
    
    func delete(mode: TimerMode, index: Int) {
        if index < 0 { return }
        timerSettings.remove(at: index)
    }
    
    func delete(indexSelected: Int) {
        if indexSelected < 0 { return }
        timerSettings.remove(at: indexSelected)
    }
    
    func get(mode: TimerMode) -> [TimerSettings] {
        return self.timerSettings
    }
    
    func done(mode: TimerMode, index: Int) {
        timerSettings[index].done = true
    }
    
    func done() {
        timerSettings[index].done = true
    }
    
    func isDone(rowSelected: Int) -> Bool {
        return timerSettings[rowSelected].done
    }
    
    func title(rowSelected: Int) -> String {
        return timerSettings[rowSelected].title
    }
    
    func minute(rowSelected: Int) -> Int {
        return timerSettings[rowSelected].minute
    }
    
    func second(rowSelected: Int) -> Int {
        return timerSettings[rowSelected].second
    }
    
    func length() -> Int {
        return timerSettings.count
    }
    
    func set(index: Int, title: String) {
        timerSettings[index].title = title
    }
    
    func set(index: Int, minute: Int) {
        timerSettings[index].minute = minute
    }
    
    func set(index: Int, second: Int) {
        timerSettings[index].second = second
    }
    
    func reset(mode: TimerMode, index: Int) {
        timerSettings[index].minute = 0
        timerSettings[index].second = 0
    }
    
    func reset() {
        for i in (0 ..< timerSettings.count) {
            timerSettings[i].done = false
        }
        self.index = -1
    }
}
