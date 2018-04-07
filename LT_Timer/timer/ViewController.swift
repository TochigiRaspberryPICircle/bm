//
//  ViewController.swift
//  timer
//
//  Created by akimach on 2018/04/01.
//  Copyright © 2018年 akimach. All rights reserved.
//

import Cocoa
import AVFoundation


class ViewController: NSViewController {
    
    private var minute = 3
    private var second = 0
    var timer = Timer()
    private var secCounting = 0.0
    private var timeStart = Date()
    
    @IBOutlet weak var buttonStart: NSButton!
    @IBOutlet weak var timerTextField: NSTextField!
    @IBOutlet weak var remainingTimeTextField: NSTextField!
    
    @IBOutlet weak var clap_R: NSImageView!
    @IBOutlet weak var clap_L: NSImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remainingTimeTextField.isHidden = true
        
        clap_R.isHidden = true
        clap_R.alphaValue = 0.0
        clap_L.isHidden = true
        clap_L.alphaValue = 0.0
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
        timerTextField.stringValue = "\(String(format: "%02d", minute)):\(String(format: "%02d", second)).000"
    }
    
    func setTimerLabel(sec: Int) {
        let m = Int(sec / 60)
        let s = Int(sec % 60)
        timerTextField.stringValue = "\(String(format: "%02d", m)):\(String(format: "%02d", s))"
    }
    
    func setTimerLabel(sec: Int, milli: Int) {
        let m = Int(sec / 60)
        let s = Int(sec % 60)
        timerTextField.stringValue = "\(String(format: "%02d", m)):\(String(format: "%02d", s)).\(String(format: "%03d", milli))"
    }
    
    @IBAction func buttonPushed(_ sender: Any) {
        
        clap_R.isHidden = true
        clap_R.alphaValue = 0.0
        clap_L.isHidden = true
        clap_L.alphaValue = 0.0
        
        timeStart = Date()
        self.secCounting = Double(minute * 60 + second)
        
        buttonStart.isEnabled = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (t) in
            
            let time = Date()
            let elapsedTime = time.timeIntervalSince(self.timeStart)
            let remainingTime = self.secCounting - elapsedTime
            let remainingMilli = remainingTime > 0.0 ? (remainingTime - floor(remainingTime)) * 1000 : 0.0
            print(remainingTime)
            print(remainingMilli)
            
            self.setTimerLabel(sec: Int(remainingTime), milli: Int(remainingMilli))
            
            if remainingTime <= 10.0 {
                self.remainingTimeTextField.isHidden = false
            } else {
                self.remainingTimeTextField.isHidden = true
            }
            
            if remainingTime <= 0.0 {
                t.invalidate()
                
                let soundName = NSSound.Name(rawValue: "clap.mp3")
                NSSound(named: soundName)?.play()
                
                NSAnimationContext.runAnimationGroup({ (context) in
                    context.duration = 2.0
                    
                    self.clap_R.isHidden = false
                    self.clap_R.animator().alphaValue = 1.0
                    self.clap_L.isHidden = false
                    self.clap_L.animator().alphaValue = 1.0
                    
                }, completionHandler: {
                    self.clap_R.isHidden = false
                    self.clap_L.isHidden = false
                })
                
                self.buttonStart.isEnabled = true
                self.remainingTimeTextField.isHidden = true
            }
        }
    }
    
    func playSound(file:String, ext:String) -> Void {
        let url = Bundle.main.url(forResource: file, withExtension: ext)!
        print(url)
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

