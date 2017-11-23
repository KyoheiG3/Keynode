//
//  Notification+Info.swift
//  Keynode
//
//  Created by Kyohei Ito on 2017/11/23.
//  Copyright © 2017年 kyohei_ito. All rights reserved.
//

extension Notification {
    var info: Info {
        return Info(userInfo: userInfo)
    }
}
