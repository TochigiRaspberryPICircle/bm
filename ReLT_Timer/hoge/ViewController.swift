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
    var timerInterval = 10.0
    var heightOfRow = 20.0
    var isSettings = false
    
    // MARK: - UI Parts
    
    @IBOutlet weak var buttonStart: NSButton!
    @IBOutlet weak var buttonStop: NSButton!
    @IBOutlet weak var imgClapLeft: NSImageView!
    @IBOutlet weak var imgClapRight: NSImageView!
    @IBOutlet weak var labelSetTime: NSTextField!
    @IBOutlet weak var labelRemainingTime: NSTextField!
    //@IBOutlet weak var buttonModes: NSPopUpButton!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var timeTableView: NSTableView!
    @IBOutlet weak var buttonAddRow: NSButton!
    @IBOutlet weak var buttonDeleteRow: NSButton!
    @IBOutlet weak var buttonResetTimeLine: NSButton!
    @IBOutlet weak var imgLion: NSImageView!
    @IBOutlet weak var buttonLastSpurt: NSButton!
    @IBOutlet weak var buttonIntervals: NSPopUpButton!
    @IBOutlet weak var buttonSettings: NSButton!
    
    
    // MARK: - Constraint for Responsive
    
    @IBOutlet weak var heightLionImage: NSLayoutConstraint!
    @IBOutlet weak var heightLeftClapImage: NSLayoutConstraint!
    
    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ltTimer.delegate = self

        // 画面リサイズ対応用のコード
        center.addObserver(forName: NSWindow.didResizeNotification, object: nil, queue: nil) { (notification) in
            print("Width:", self.view.window?.frame.size.width ?? 0.0)
            print("Height:", self.view.window?.frame.size.height ?? 0.0)
            
            let height = (self.view.window?.frame.size.height)!
            self.heightLionImage.constant = height * (2.0 / 3.0)
            self.heightLeftClapImage.constant = height * (1.0 / 4.0)
            
            if height < 300 {
                self.labelSetTime.font = NSFont(name: "Osaka−等幅", size: 50)
                self.labelRemainingTime.font = NSFont(name: "Osaka−等幅", size: 30)
            } else if height > 1200 {
                self.labelSetTime.font = NSFont(name: "Osaka−等幅", size: 500)
                self.labelRemainingTime.font = NSFont(name: "Osaka−等幅", size: 135)
            } else {
                let point_rate = (height - 300) / 1200
                self.labelSetTime.font = NSFont(name: "Osaka−等幅", size: 450 * point_rate + 55)
                self.labelRemainingTime.font = NSFont(name: "Osaka−等幅", size: 150 * point_rate + 35)
            }
        }
        
        imgClapLeft.isHidden = true
        imgClapRight.isHidden = true
        scrollView.isHidden = true
        timeTableView.isHidden = true
        buttonStop.isEnabled = false
        buttonAddRow.isHidden = true
        buttonDeleteRow.isHidden = true
        buttonResetTimeLine.isHidden = true
        buttonIntervals.isHidden = true
        buttonLastSpurt.isHidden = true
        
        //imgLion.isHidden = true
        imgLion.isHidden = false
        imgLion.image = NSImage(named: NSImage.Name(rawValue: "toteka"))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if timeLine.length() == 0 {
            buttonStart.isEnabled = false
        } else {
            buttonStart.isEnabled = true
        }
        
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
    
    // MARK: - IBAction
    
    private func startTimer() {
        if timeLine.length() == 0 { return }
        guard let remainingTimeSec = self.ltTimer.remainingTimeSec else {
            return
        }

        DispatchQueue.main.async {
            if !self.buttonStart.isEnabled { return }
            self.imgClapLeft.isHidden = true
            self.imgClapRight.isHidden = true
            self.imgLion.isHidden = true
            self.labelSetTime.isHidden = false
            self.labelRemainingTime.isHidden = false
            self.buttonStart.isEnabled = false
            self.buttonStop.isEnabled = true
            
            self.timeTableView.deselectRow(self.timeLine.index - 1)
            self.timeTableView.selectRowIndexes(IndexSet(integer: self.timeLine.index), byExtendingSelection: false)
            self.timeTableView.reloadData()
        }
        
        if remainingTimeSec > 0 {
            do {
                return try self.ltTimer.restart()
            } catch let error as NSError {
                print(error.localizedDescription)
                return
            }
        }

        if timeLine.index < 0 {
            ltTimer.reset()
            timeLine.reset()
            timeLine.index = 0
            
            DispatchQueue.main.async {
                self.labelRemainingTime.stringValue = self.timeLine.title()
            }
            
            return self.ltTimer.start(min: timeLine.minute(), sec: timeLine.second())
        }
        
        if timeLine.index >= 0 {
            DispatchQueue.main.async {
                self.labelRemainingTime.stringValue = self.timeLine.title()
            }
            
            return self.ltTimer.start(min: timeLine.minute(), sec: timeLine.second())
        }
    }
    
    private func stopTimer() {
        self.ltTimer.stop()
        
        DispatchQueue.main.async {
            self.buttonStart.isEnabled = true
            self.buttonStop.isEnabled = false
        }
    }
    
    @IBAction func startTimer(_ sender: Any) {
        startTimer()
    }
    
    @IBAction func stopTimer(_ sender: Any) {
        stopTimer()
    }
    
    @IBAction func changeMode(_ sender: Any) {
        isSettings = !isSettings
        if isSettings == false {
            if self.ltTimer.isCounting {
                buttonStart.isEnabled = false
                buttonStop.isEnabled = true
            } else {
                buttonStart.isEnabled = true
                buttonStop.isEnabled = false
            }
            if timeLine.length() == 0 {
                buttonStart.isEnabled = false
                buttonStop.isEnabled = false
            }
            if timeLine.index < 0 {
                labelRemainingTime.stringValue = ""
                imgLion.image = NSImage(named: NSImage.Name(rawValue: "toteka"))
                imgLion.isHidden = false
            }
            labelSetTime.isHidden = false
            labelRemainingTime.isHidden = false
            scrollView.isHidden = true
            timeTableView.isHidden = true
            buttonAddRow.isHidden = true
            buttonDeleteRow.isHidden = true
            buttonStart.isHidden = false
            buttonStop.isHidden = false
            buttonResetTimeLine.isHidden = true
            buttonIntervals.isHidden = true
            buttonLastSpurt.isHidden = true
            buttonSettings.title = "Settings"
        } else {
            
            labelSetTime.isHidden = true
            labelRemainingTime.isHidden = true
            scrollView.isHidden = false
            timeTableView.isHidden = false
            buttonAddRow.isHidden = false
            buttonDeleteRow.isHidden = false
            buttonStart.isHidden = true
            buttonStop.isHidden = true
            buttonResetTimeLine.isHidden = false
            imgClapLeft.isHidden = true
            imgClapRight.isHidden = true
            imgLion.isHidden = true
            buttonIntervals.isHidden = false
            buttonLastSpurt.isHidden = false
            buttonSettings.title = "Back"
        }
        timeTableView.reloadData()
    }
    
    @IBAction func addRow(_ sender: Any) {
        timeLine.add()
        timeTableView.reloadData()
    }
    
    @IBAction func deleteRow(_ sender: Any) {
        timeLine.delete(indexSelected: timeTableView.selectedRow)
        timeTableView.reloadData()
    }
    
    @IBAction func resetTimeLine(_ sender: Any) {
        ltTimer.reset()
        timeLine.reset()
        timeTableView.reloadData()
    }
    
    @IBAction func changeTimerIntervals(_ sender: Any) {
        switch buttonIntervals.title {
        case "インターバル 0秒":
            self.timerInterval = 0.0
        case "インターバル 5秒":
            self.timerInterval = 5.0
        case "インターバル 10秒":
            self.timerInterval = 10.0
        case "インターバル 30秒":
            self.timerInterval = 30.0
        case "インターバル 60秒":
            self.timerInterval = 60.0
        default:
            self.timerInterval = 10.0
        }
    }
    
    @IBAction func changeLastSpurt(_ sender: Any) { }
    
    
    // MARK: - LTTimerProtocol
    
    func lastspurt() {
        if self.buttonLastSpurt.state.rawValue == 1 {
            print("[mac -> raspi]: GET /lastspurt")
            let url = URL(string: baseURL + "/lastspurt")
            let request = URLRequest(url: url!, timeoutInterval: 5)
            Alamofire.request(request).responseString { (res) in
                print(res)
            }
        }
        
        DispatchQueue.main.async {
            self.labelRemainingTime.isHidden = false
            if self.buttonLastSpurt.state.rawValue == 1 {
                self.labelRemainingTime.stringValue = "拍手の準備をッ!!!"
            }
        }
    }
    
    func finish() {
        DispatchQueue.main.async {
            self.buttonStart.isEnabled = true
            self.buttonStop.isEnabled = false
            
            self.imgLion.image = NSImage(named: NSImage.Name(rawValue: "lion"))
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 1.0
                self.labelSetTime.animator().stringValue = ""
                self.labelRemainingTime.animator().stringValue = "\\88888888/"
                self.imgClapLeft.animator().isHidden = false
                self.imgClapRight.animator().isHidden = false
                self.imgLion.animator().isHidden = false
            }, completionHandler: nil)
        }
        
        let notification = NSUserNotification()
        notification.title = "とてか05"
        print("timerIndex:", timeLine.index)
        notification.subtitle = self.timeLine.title()
        notification.informativeText = "終了しました！"
        notification.contentImage =  NSImage(named: NSImage.Name(rawValue: "lion"))
        notification.userInfo = ["title" : "とてか05"]
        notification.soundName = NSUserNotificationDefaultSoundName
        //notification.deliveryDate = Date().addingTimeInterval(0.1)
        NSUserNotificationCenter.default.deliver(notification)
        
        timeLine.done()
        self.timeLine.next()
        
        if timeLine.index >= self.timeLine.length() {
            ltTimer.reset()
            timeLine.reset()
        } else {
            DispatchQueue.main.async {
                self.buttonStart.isEnabled = false
                self.buttonStop.isEnabled = false
            }
            Timer.scheduledTimer(withTimeInterval: self.timerInterval, repeats: false) { (t) in
                DispatchQueue.main.async {
                    self.buttonStart.isEnabled = true
                    self.buttonStop.isEnabled = true
                }
                print("次のスタート")
                self.startTimer()
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
        print("startTimer(request: HttpRequest)")
        DispatchQueue.main.async {
            self.startTimer()
        }
        
        return HttpResponse.ok(HttpResponseBody.json(["type": "start", "status":0] as AnyObject))
    }
    
    func stopTimer(request: HttpRequest) -> HttpResponse {
        
        DispatchQueue.main.async {
            self.stopTimer()
        }
        return HttpResponse.ok(HttpResponseBody.json(["type": "stop", "status":0] as AnyObject))
    }
    
    // MARK: - NSTableView
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return timeLine.length()
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let id = tableColumn?.identifier.rawValue else { return "" }
        
        if id == "AutomaticTableColumnIdentifier.0" {
            return timeLine.isDone(rowSelected: row) ? "✓" : ""
        } else if id == "AutomaticTableColumnIdentifier.1" {
            return timeLine.title(rowSelected: row)
        } else if id == "AutomaticTableColumnIdentifier.2" {
            return String(timeLine.minute(rowSelected: row))
        } else if id == "AutomaticTableColumnIdentifier.3" {
            return String(timeLine.second(rowSelected: row))
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
            timeLine.set(index: row, title: text)
        } else if id == "AutomaticTableColumnIdentifier.2" {
            guard let min = Int(text) else {
                return
            }
            timeLine.set(index: row, minute: min)
        } else if id == "AutomaticTableColumnIdentifier.3" {
            guard let sec = Int(text) else {
                return
            }
            timeLine.set(index: row, second: sec)
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30.0
    }
}

