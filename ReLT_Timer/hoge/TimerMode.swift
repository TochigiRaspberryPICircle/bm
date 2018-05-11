//
//  TimerMode.swift
//  hoge
//
//  Created by akimach on 2018/05/01.
//  Copyright © 2018年 akimach. All rights reserved.
//

import Foundation

enum TimerMode {
    case Normal
    case Settings
    
    static func create(mode: String) -> TimerMode {
        switch mode {
        case "":
            return TimerMode.Normal
        case "Settings":
            return TimerMode.Settings
        default:
            return TimerMode.Normal
        }
    }
}
