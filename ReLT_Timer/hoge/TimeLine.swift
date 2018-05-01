//
//  TimeLine.swift
//  hoge
//
//  Created by akimach on 2018/05/01.
//  Copyright © 2018年 akimach. All rights reserved.
//

import Foundation

class TimeLine {
    var timeLinePanel: [TimerSettings] = [
        (false, "パネル1 - イントロ", 22),
        (false, "パネル1 - お題1", 12),
        (false, "パネル1 - お題2", 12),
        (false, "パネル1 - お題3", 12),
        (false, "パネル1 - お題4", 12),
        (false, "パネル2 - イントロ", 22),
        (false, "パネル2 - お題1", 12),
        (false, "パネル2 - お題2", 12),
        (false, "パネル2 - お題3", 12),
        (false, "パネル2 - お題4", 12),
        ]
    var timeLineLT: [TimerSettings] = []
    
    func add(mode: TimerMode) {
        switch mode {
        case .Normal: break
        case .Panel:
            timeLinePanel.append((done: false, title: "notitle", minute: 1))
        case .LT:
            timeLineLT.append((done: false, title: "notitle", minute: 1))
        }
    }
    
    func delete(mode: TimerMode, index: Int) {
        if index < 0 { return }
        switch mode {
        case .Normal: break
        case .Panel:
            timeLinePanel.remove(at: index)
        case .LT:
            timeLineLT.remove(at: index)
        }
    }
    
    func get(mode: TimerMode) -> [TimerSettings] {
        switch mode {
        case .Normal:
            return []
        case .Panel:
            return self.timeLinePanel
        case .LT:
            return self.timeLineLT
        }
    }
    
    func done(mode: TimerMode, index: Int) {
        switch mode {
        case .Normal: break
        case .Panel:
            timeLinePanel[index].done = true
        case .LT:
            timeLineLT[index].done = true
        }
    }
    
    func set(mode: TimerMode, index: Int, title: String) {
        switch mode {
        case .Normal: break
        case .Panel:
            timeLinePanel[index].title = title
        case .LT:
            timeLineLT[index].title = title
        }
    }
    
    func set(mode: TimerMode, index: Int, minute: Int) {
        switch mode {
        case .Normal: break
        case .Panel:
            timeLinePanel[index].minute = minute
        case .LT:
            timeLineLT[index].minute = minute
        }
    }
}
