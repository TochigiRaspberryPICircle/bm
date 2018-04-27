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
    
    public var remainingTimeSec: Double? = nil
    public var delegate: LTTimerProtocol? = nil
    
    public func start(min: Int, sec: Int) {
        self.settimeSec = Double(min * 60 + sec)
        fire()
    }
    
    public func restart() throws {
        guard let remainingTimeSec = remainingTimeSec else {
            throw NSError(domain: "Remaining time not set", code: -1, userInfo: nil)
        }
        self.settimeSec = remainingTimeSec
        fire()
    }
    
    private func fire(interval: Double = 0.05) {
        self.starttime = Date()
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: self.onUpdate)
    }
    
    private func onUpdate(timer: Timer) {
        let elapsedTime = Date().timeIntervalSince(starttime)
        self.remainingTimeSec = ceil(self.settimeSec - elapsedTime)
        
        self.delegate?.onUpdate(remainingSec: Int(self.remainingTimeSec!))
        
        if 0.0 < self.remainingTimeSec! && self.remainingTimeSec! <= 10.0 && !self.isLastspurtAttached {
            self.isLastspurtAttached = true
            self.delegate?.lastspurt()
        } else if self.remainingTimeSec! <= 0.0 {
            self.isLastspurtAttached = false
            self.delegate?.finish()
            timer.invalidate()
        }
    }
    
    public func stop() {
        timer.invalidate()
    }
    
    public func reset() {
        timer.invalidate()
        clear()
    }
    
    private func clear() {
        settimeSec = 0.0
        remainingTimeSec = 0.0
    }
    
}
