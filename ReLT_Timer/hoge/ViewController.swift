//
//  ViewController.swift
//  hoge
//
//  Created by akimach on 2018/04/26.
//  Copyright © 2018年 akimach. All rights reserved.
//

import Cocoa


class ViewController: NSViewController, LTTimerProtocol {
    
    let center = NotificationCenter.default
    var ltTimer = LTTimer()
    var isRestart = false
    
    var setMin = 0
    var setSec = 0
    var settime: (Int, Int) {
        get {
            return (setMin, setSec)
        }
        set(t) {
            setMin = t.0
            setSec = t.1
            labelSetTime.stringValue = "\(String(format: "%02d", setMin)):\(String(format: "%02d", setSec))"
        }
    }
    
    var remainingMin = 0
    var remainingSec = 0
    var remainingTime: (Int, Int) {
        get {
            return (remainingMin, remainingSec)
        }
        set(t) {
            remainingMin = t.0
            remainingSec = t.1
            labelRemainingTime.stringValue = "\(String(format: "%02d", remainingMin)):\(String(format: "%02d", remainingSec))"
        }
    }
    
    // MARK: - UI Parts
    
    @IBOutlet weak var buttonStart: NSButton!
    @IBOutlet weak var buttonStop: NSButton!
    @IBOutlet weak var buttonReset: NSButton!
    @IBOutlet weak var imgClapLeft: NSImageView!
    @IBOutlet weak var imgClapRight: NSImageView!
    @IBOutlet weak var labelSetTime: NSTextField!
    @IBOutlet weak var labelRemainingTime: NSTextField!
    @IBOutlet weak var textFieldMinute: NSTextField!
    @IBOutlet weak var textFieldSecond: NSTextField!
    
    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ltTimer.delegate = self

        // 画面リサイズ対応用のコード
        center.addObserver(forName: NSWindow.didResizeNotification, object: nil, queue: nil) { (notification) in
            print("Width:", self.view.window?.frame.size.width ?? 0.0)
            print("Height:", self.view.window?.frame.size.height ?? 0.0)
        }
        
        imgClapLeft.isHidden = true
        imgClapRight.isHidden = true
        
        buttonStop.isEnabled = false
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        guard let textField: NSTextField = obj.object as? NSTextField else {
            return
        }
        guard let numberTime = Int(textField.stringValue) else {
            return
        }
        
        if textField == textFieldMinute {
            settime = (numberTime, settime.1)
        } else if textField == textFieldSecond {
            settime = (settime.0, numberTime)
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func startTimer(_ sender: Any) {
        if !buttonStart.isEnabled { return }
        buttonStart.isEnabled = false
        buttonStop.isEnabled = true
        buttonReset.isEnabled = false
        
        imgClapLeft.isHidden = true
        imgClapRight.isHidden = true
        
        if !isRestart {
            return ltTimer.start(min: settime.0, sec: settime.1)
        }
        do {
            try ltTimer.restart()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func stopTimer(_ sender: Any) {
        buttonStart.isEnabled = true
        buttonStop.isEnabled = false
        buttonReset.isEnabled = true
        isRestart = true
        ltTimer.stop()
    }
    
    @IBAction func resetTimer(_ sender: Any) {
        // TODO: -
        isRestart = false
        settime = (0, 0)
        remainingTime = (0, 0)
        ltTimer.reset()
    }
    
    // MARK: - LTTimerProtocol
    
    func lastspurt() {
        print("[mac -> raspi]: GET /lastspurt")
    }
    
    func finish() {
        buttonStart.isEnabled = true
        buttonStop.isEnabled = false
        buttonReset.isEnabled = true
        isRestart = false
        
        self.labelSetTime.stringValue = "888888"
        self.labelRemainingTime.stringValue = "88888888"
        imgClapLeft.isHidden = false
        imgClapRight.isHidden = false
        
        print("[mac -> raspi]: GET /finish")
    }
    
    func onUpdate(remainingSec: Int) {
        let m = Int(remainingSec / 60)
        let s = Int(remainingSec % 60)
        remainingTime = (m, s)
    }
}

