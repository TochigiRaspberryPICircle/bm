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
    case Panel
    case LT
    
    static func create(mode: String) -> TimerMode {
        switch mode {
        case "Normal":
            return TimerMode.Normal
        case "Panel":
            return TimerMode.Panel
        case "LT":
            return TimerMode.LT
        default:
            return TimerMode.Normal
        }
    }
}
