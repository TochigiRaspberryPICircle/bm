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
    private var settime: Double = 0.0 // Second
    private var remainingTime: Double? = nil // Second
    private var isLastspurtAttached: Bool = false
    public var labelRemainingTime: NSTextField? = nil
    public var delegate: LTTimerProtocol? = nil
    
    public func start(min: Int, sec: Int) {
        self.settime = Double(min * 60 + sec)
        fire()
    }
    
    public func restart() throws {
        guard let remainingTime = remainingTime else {
            throw NSError(domain: "Remaining time not set", code: -1, userInfo: nil)
        }
        self.settime = remainingTime
        fire()
    }
    
    private func fire(interval: Double = 0.05) {
        let starttime = Date()
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { (timer) in
            let elapsedTime = Date().timeIntervalSince(starttime)
            self.remainingTime = ceil(self.settime - elapsedTime)
            self.delegate?.onUpdate(remainingSec: Int(self.remainingTime!))
            
            if 0.0 < self.remainingTime! && self.remainingTime! <= 10.0 && !self.isLastspurtAttached {
                self.isLastspurtAttached = true
                self.delegate?.lastspurt()
            } else if self.remainingTime! <= 0.0 {
                self.isLastspurtAttached = false
                self.delegate?.finish()
                timer.invalidate()
            }
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
        settime = 0.0
        remainingTime = 0.0
    }
    
}
