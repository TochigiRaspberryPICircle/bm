//
//  LTTimer.swift
//  hoge
//
//  Created by akimach on 2018/04/26.
//  Copyright © 2018年 akimach. All rights reserved.
//

import Cocoa

class LTTimer {
    
    
    private var timer = Timer()
    private var starttime = Date()
    private var settimeSec: Double = 0.0
    private var isLastspurtAttached: Bool = false
    
    public var remainingTimeSec: Double? = 0.0
    public var delegate: LTTimerProtocol? = nil
    
    public var min: Int = 0
    public var sec: Int = 0
    
    public var isCounting = false
    
    static func createTimers(timeLine: [TimerSettings], delegate: LTTimerProtocol) -> [LTTimer] {
        var timers: [LTTimer] = []
        for t in timeLine {
            let timer = LTTimer(min: t.minute, sec: 0)
            timer.delegate = delegate
            timers.append(timer)
        }
        return timers
    }
    
    init() { }
    
    init(min: Int, sec: Int) {
        self.min = min
        self.sec = sec
    }
    
    public func start(min: Int, sec: Int) {
        if isCounting { return }
        self.settimeSec = Double(min * 60 + sec)
        fire()
    }
    
    public func start() {
        if isCounting { return }
        self.settimeSec = Double(self.min * 60 + self.sec)
        fire()
    }
    
    public func restart() throws {
        if isCounting { return }
        guard let remainingTimeSec = remainingTimeSec else {
            throw NSError(domain: "Remaining time not set", code: -1, userInfo: nil)
        }
        self.settimeSec = remainingTimeSec
        self.fire()
    }
    
    private func fire(interval: Double = 0.05) {
        self.starttime = Date()
        self.isCounting = true
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: self.onUpdate)
        print(self.timer)
    }
    
    private func onUpdate(timer: Timer) {
        self.timer = timer
        
        self.isCounting = true
        let elapsedTime = Date().timeIntervalSince(starttime)
        self.remainingTimeSec = ceil(self.settimeSec - elapsedTime)
        self.delegate?.onUpdate(remainingSec: Int(self.remainingTimeSec!))
        
        if 0.0 < self.remainingTimeSec! && self.remainingTimeSec! <= 10.0 && !self.isLastspurtAttached {
            self.isLastspurtAttached = true
            self.delegate?.lastspurt()
        } else if self.remainingTimeSec! <= 0.0 {
            self.isLastspurtAttached = false
            self.delegate?.finish()
            self.isCounting = false
            self.timer.invalidate()
        }
    }
    
    public func stop() {
        self.isCounting = false
        timer.invalidate()
    }
    
    public func reset() {
        self.timer.invalidate()
        clear()
    }
    
    public func clear() {
        self.isCounting = false
        settimeSec = 0.0
        remainingTimeSec = 0.0
    }
    
}
