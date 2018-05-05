//
//  AppDelegate.swift
//  hoge
//
//  Created by akimach on 2018/04/26.
//  Copyright © 2018年 akimach. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        NSUserNotificationCenter.default.delegate = self
        let notification = NSUserNotification()
        notification.title = "タイトル"
        notification.subtitle = "サブタイトル"
        notification.informativeText = "本文"
        notification.contentImage =  NSImage(named: NSImage.Name(rawValue: "lion"))
        notification.userInfo = ["title" : "タイトル"]
        //NSUserNotificationCenter.default.deliver(notification)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        let info = notification.userInfo as! [String:String]
        print("Title:", info["title"]!)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

