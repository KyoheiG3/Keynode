//
//  UIApplication+UIResponder.swift
//  Keynode
//
//  Created by Kyohei Ito on 2017/11/23.
//  Copyright © 2017年 kyohei_ito. All rights reserved.
//

public extension UIApplication {
    /// UIResponderBecomeFirstResponder notification by first responder
    public func needsNotificationFromFirstResponder(_ from: AnyObject?) {
        sendAction(#selector(UIResponder.firstResponder(_:)), to: nil, from: from, for: nil)
    }
}
