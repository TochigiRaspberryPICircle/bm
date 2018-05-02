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

class ViewController: NSViewController, LTTimerProtocol, NSTableViewDelegate, NSTableViewDataSource {
    
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
            labelSetTime.stringValue = "\(String(format: "%02d", remainingMin)):\(String(format: "%02d", remainingSec))"
        }
    }
    var mode = TimerMode.Normal
    let baseURL = "http://raspberrypi.local"
    var timeLine = TimeLine()
    var timerIndex = 0
    
    // MARK: - UI Parts
    
    @IBOutlet weak var buttonStart: NSButton!
    @IBOutlet weak var buttonStop: NSButton!
    @IBOutlet weak var buttonReset: NSButton!
    
    @IBOutlet weak var imgClapLeft: NSImageView!
    @IBOutlet weak var imgClapRight: NSImageView!
    
    @IBOutlet weak var labelSetTime: NSTextField!
    @IBOutlet weak var labelRemainingTime: NSTextField!
    
    @IBOutlet weak var buttonModes: NSPopUpButton!
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var timeTableView: NSTableView!
    
    @IBOutlet weak var buttonAddRow: NSButton!
    @IBOutlet weak var buttonDeleteRow: NSButton!
    
    
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
        scrollView.isHidden = true
        timeTableView.isHidden = true
        buttonStop.isEnabled = false

        buttonAddRow.isHidden = true
        buttonDeleteRow.isHidden = true
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
//        guard let textField: NSTextField = obj.object as? NSTextField else {
//            return
//        }
//        guard let numberTime = Int(textField.stringValue) else {
//            return
//        }
        
//        if textField == textFieldMinute {
//            settime = (numberTime, settime.sec)
//        } else if textField == textFieldSecond {
//            settime = (settime.min, numberTime)
//        }
    }
    
    // MARK: - IBAction
    
    private func startTimer() {
        
        if let remainingTimeSec = self.ltTimer.remainingTimeSec {
            if remainingTimeSec > 0 {
                do {
                    try self.ltTimer.restart()
                    return
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.imgClapLeft.isHidden = true
            self.imgClapRight.isHidden = true
        }

        switch self.mode {
        case .Normal:
            if timerIndex < 0 {
                timerIndex = 0
                for i in (0 ..< timeLine.get(mode: self.mode).count) {
                    timeLine.done(mode: mode, index: i)
                    timeTableView.reloadData()
                }
                self.ltTimer.start(min: timeLine.get(mode: self.mode)[timerIndex].minute, sec: 0)
                return
            }
            
            if timeLine.get(mode: self.mode).count == 0 {
                return
            } else if timeLine.get(mode: self.mode).count == 1 {
                print("1")
            } else if timeLine.get(mode: self.mode).count > 1 {
                print(">=1")
            }
            self.labelRemainingTime.stringValue = timeLine.get(mode: self.mode)[timerIndex].title
            self.ltTimer.start(min: timeLine.get(mode: self.mode)[timerIndex].minute, sec: timeLine.get(mode: self.mode)[timerIndex].second)
            DispatchQueue.main.async {
                if !self.buttonStart.isEnabled { return }
                self.buttonStart.isEnabled = false
                self.buttonStop.isEnabled = true
                self.buttonReset.isEnabled = false
            }
            DispatchQueue.main.async {
                self.timeTableView.deselectRow(self.timerIndex-1)
                self.timeTableView.selectRowIndexes(IndexSet(integer: self.timerIndex), byExtendingSelection: false)
            }
        case .Settings:
            break
        }
    }
    
    private func stopTimer() {

        switch self.mode {
        case .Normal:
            self.ltTimer.stop()
        case .Settings:
            self.ltTimer.stop()
        }
        
        DispatchQueue.main.async {
            self.buttonStart.isEnabled = true
            self.buttonStop.isEnabled = false
            self.buttonReset.isEnabled = true
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
        timeLine.reset(mode: self.mode, index: self.timerIndex)
        ltTimer.reset()
    }
    
    @IBAction func changeMode(_ sender: Any) {
        self.mode = TimerMode.create(mode: buttonModes.title)
        switch self.mode {
        case .Normal:
            labelSetTime.isHidden = false
            labelRemainingTime.isHidden = false
            
            scrollView.isHidden = true
            timeTableView.isHidden = true
            
            buttonAddRow.isHidden = true
            buttonDeleteRow.isHidden = true
            
            buttonStart.isHidden = false
            buttonReset.isHidden = false
            buttonStop.isHidden = false
        case .Settings:
            labelSetTime.isHidden = true
            labelRemainingTime.isHidden = true
            
            scrollView.isHidden = false
            timeTableView.isHidden = false
            
            buttonAddRow.isHidden = false
            buttonDeleteRow.isHidden = false
            
            buttonStart.isHidden = true
            buttonReset.isHidden = true
            buttonStop.isHidden = true
        }
        timeTableView.reloadData()
    }
    
    @IBAction func addRow(_ sender: Any) {
        switch self.mode {
        case .Normal: break
        case .Settings:
            timeLine.add(mode: self.mode)
            timeTableView.reloadData()
        }
    }
    
    @IBAction func deleteRow(_ sender: Any) {
        switch self.mode {
        case .Normal: break
        case .Settings:
            timeLine.delete(mode: self.mode, index: timeTableView.selectedRow)
            timeTableView.reloadData()
        }
    }
    
    // MARK: - LTTimerProtocol
    
    func lastspurt() {
        print("[mac -> raspi]: GET /lastspurt")
        let url = URL(string: baseURL + "/lastspurt")
        let request = URLRequest(url: url!, timeoutInterval: 5)
        Alamofire.request(request).responseString { (res) in
            print(res)
        }
        
        DispatchQueue.main.async {
            self.labelRemainingTime.isHidden = false
            self.labelRemainingTime.stringValue = "拍手の準備を！"
        }
    }
    
    func finish() {
        switch self.mode {
        case .Normal:
            DispatchQueue.main.async {
                self.buttonStart.isEnabled = true
                self.buttonStop.isEnabled = false
                self.buttonReset.isEnabled = true
                self.labelSetTime.stringValue = "888888"
                self.labelRemainingTime.stringValue = "88888888"
                self.imgClapLeft.isHidden = false
                self.imgClapRight.isHidden = false
            }
        case .Settings:
            timeLine.done(mode: mode, index: timerIndex)
            self.timerIndex += 1
            if self.timerIndex >= self.timeLine.get(mode: mode).count {
                self.timerIndex = -1
            } else {
                startTimer()
            }
            DispatchQueue.main.async {
                self.buttonStart.isEnabled = true
                self.buttonStop.isEnabled = false
                self.buttonReset.isEnabled = true
                self.timeTableView.reloadData()
            }
        }
        
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
    
    // MARK: - NSTableView
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return timeLine.get(mode: mode).count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let id = tableColumn?.identifier.rawValue else { return "" }
        
        if id == "AutomaticTableColumnIdentifier.0" {
            return timeLine.get(mode: self.mode)[row].done ? "✓" : ""
        } else if id == "AutomaticTableColumnIdentifier.1" {
            return timeLine.get(mode: self.mode)[row].title
        } else if id == "AutomaticTableColumnIdentifier.2" {
            return String(timeLine.get(mode: self.mode)[row].minute)
        } else if id == "AutomaticTableColumnIdentifier.3" {
            return String(timeLine.get(mode: self.mode)[row].second)
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard let id = tableColumn?.identifier.rawValue else { return }
        guard let text = object as? String else { return }
        
        if id == "AutomaticTableColumnIdentifier.0" {
            return
        } else if id == "AutomaticTableColumnIdentifier.1" {
            timeLine.set(mode: mode, index: row, title: text)
        } else if id == "AutomaticTableColumnIdentifier.2" {
            guard let min = Int(text) else {
                return
            }
            timeLine.set(mode: mode, index: row, minute: min)
        } else if id == "AutomaticTableColumnIdentifier.3" {
            guard let sec = Int(text) else {
                return
            }
            timeLine.set(mode: mode, index: row, second: sec)
            print(timeLine.timerSettings)
        }
    }
    
}

