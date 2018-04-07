//
//  ViewController.swift
//  timer
//
//  Created by akimach on 2018/04/01.
//  Copyright © 2018年 akimach. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    private var minute = 3
    private var second = 0
    var timer = Timer()
    private var secCounting = 0.0
    private var timeStart = Date()
    
    @IBOutlet weak var buttonStart: NSButton!
    @IBOutlet weak var timerTextField: NSTextField!
    @IBOutlet weak var remainingTimeTextField: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remainingTimeTextField.isHidden = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func minuteChanged(_ sender: Any) {
        let textField = sender as! NSTextField
        print(textField.stringValue)

        minute = Int(textField.stringValue) ?? 0
        setTimerLabel()
    }
    
    @IBAction func secondChanged(_ sender: Any) {
        let textField = sender as! NSTextField
        print(textField.stringValue)
        
        second = Int(textField.stringValue) ?? 0
        setTimerLabel()
    }
    
    func setTimerLabel() {
        timerTextField.stringValue = "\(String(format: "%02d", minute)):\(String(format: "%02d", second))"
    }
    
    func setTimerLabel(sec: Int) {
        let m = Int(sec / 60)
        let s = Int(sec % 60)
        timerTextField.stringValue = "\(String(format: "%02d", m)):\(String(format: "%02d", s))"
    }
    
    @IBAction func buttonPushed(_ sender: Any) {
        
        timeStart = Date()
        self.secCounting = Double(minute * 60 + second)
        
        buttonStart.isEnabled = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (t) in
            let time = Date()
            let elapsedTime = time.timeIntervalSince(self.timeStart) as Double
            let remainingTime = self.secCounting - elapsedTime
            self.setTimerLabel(sec: Int(remainingTime))
            
            if remainingTime <= 10.0 {
                self.remainingTimeTextField.isHidden = false
            } else {
                self.remainingTimeTextField.isHidden = true
            }
            
            if remainingTime <= 0.0 {
                t.invalidate()
                self.buttonStart.isEnabled = true
                self.remainingTimeTextField.isHidden = true
            }
        }
        
    }
}

