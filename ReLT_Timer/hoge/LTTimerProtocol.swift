//
//  LTTimerProtocol.swift
//  hoge
//
//  Created by akimach on 2018/04/26.
//  Copyright © 2018年 akimach. All rights reserved.
//

protocol LTTimerProtocol {
    func lastspurt()
    func finish()
    func onUpdate(remainingSec: Int)
}
