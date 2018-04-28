//
//  ViewController.swift
//  hoge
//
//  Created by akimach on 2018/04/26.
//  Copyright © 2018年 akimach. All rights reserved.
//

import Cocoa
import Swifter
import SwiftyJSON
import Dispatch
import Alamofire

class ViewController: NSViewController, LTTimerProtocol {
    
    let center = NotificationCenter.default
    let server = HttpServer()
    var ltTimer = LTTimer()
    let port: UInt16 = 8888
    var (setMin, setSec) = (0, 0)
    var settime: (min: Int, sec: Int) {
        get { return (setMin, setSec) }
        set(t) {
            (setMin, setSec) = (t.min, t.sec)
            labelSetTime.stringValue = "\(String(format: "%02d", setMin)):\(String(format: "%02d", setSec))"
        }
    }
    var (remainingMin, remainingSec) = (0, 0)
    var remainingTime: (min: Int, sec: Int) {
        get { return (remainingMin, remainingSec) }
        set(t) {
            (remainingMin, remainingSec) = (t.min, t.sec)
            labelRemainingTime.stringValue = "\(String(format: "%02d", remainingMin)):\(String(format: "%02d", remainingSec))"
        }
    }
    let baseURL = "http://raspberrypi.local"
    
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
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // MARK: - HTTP Server
        
        server["/"] = { .ok(.html("You asked for \($0)"))  }
        server["/start"] = self.startTimer
        server["/stop"] = self.stopTimer
        
        do {
            try server.start(self.port, forceIPv4: true)
            print("Server has started ( port = \(try server.port()) ). Try to connect now...")
        } catch {
            print("Server start error: \(error)")
        }
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
            settime = (numberTime, settime.sec)
        } else if textField == textFieldSecond {
            settime = (settime.min, numberTime)
        }
    }
    
    // MARK: - IBAction
    
    private func startTimer() {
        DispatchQueue.main.async {
            if !self.buttonStart.isEnabled { return }
            self.buttonStart.isEnabled = false
            self.buttonStop.isEnabled = true
            self.buttonReset.isEnabled = false
            self.imgClapLeft.isHidden = true
            self.imgClapRight.isHidden = true
            
            guard let remainingTimeSec = self.ltTimer.remainingTimeSec else {
                return self.ltTimer.start(min: self.settime.min, sec: self.settime.sec)
            }
            if remainingTimeSec <= 0 {
                return self.ltTimer.start(min: self.settime.min, sec: self.settime.sec)
            }
            do {
                try self.ltTimer.restart()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    private func stopTimer() {
        DispatchQueue.main.async {
            self.buttonStart.isEnabled = true
            self.buttonStop.isEnabled = false
            self.buttonReset.isEnabled = true
            self.ltTimer.stop()
        }
    }
    
    @IBAction func startTimer(_ sender: Any) {
        startTimer()
    }
    
    @IBAction func stopTimer(_ sender: Any) {
        stopTimer()
    }
    
    @IBAction func resetTimer(_ sender: Any) {
        // TODO: -
        settime = (0, 0)
        remainingTime = (0, 0)
        ltTimer.reset()
    }
    
    // MARK: - LTTimerProtocol
    
    func lastspurt() {
        print("[mac -> raspi]: GET /lastspurt")
        let url = URL(string: baseURL + "/lastspurt")
        let request = URLRequest(url: url!, timeoutInterval: 5)
        Alamofire.request(request).responseString { (res) in
            print(res)
        }
    }
    
    func finish() {
        buttonStart.isEnabled = true
        buttonStop.isEnabled = false
        buttonReset.isEnabled = true
        
        self.labelSetTime.stringValue = "888888"
        self.labelRemainingTime.stringValue = "88888888"
        imgClapLeft.isHidden = false
        imgClapRight.isHidden = false
        
        print("[mac -> raspi]: GET /finish")
        let url = URL(string: baseURL + "/finish")
        let request = URLRequest(url: url!, timeoutInterval: 5)
        Alamofire.request(request).responseString { (res) in
            print(res)
        }
    }
    
    func onUpdate(remainingSec: Int) {
        let m = Int(remainingSec / 60)
        let s = Int(remainingSec % 60)
        remainingTime = (m, s)
    }
    
    // MARK: - HTTP
    
    func startTimer(request: HttpRequest) -> HttpResponse {
        startTimer()
        return HttpResponse.ok(HttpResponseBody.json(["type": "start", "status":0] as AnyObject))
    }
    
    func stopTimer(request: HttpRequest) -> HttpResponse {
        stopTimer()
        return HttpResponse.ok(HttpResponseBody.json(["type": "stop", "status":0] as AnyObject))
    }
}

