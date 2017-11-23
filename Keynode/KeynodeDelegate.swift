//
//  KeynodeDelegate.swift
//  Keynode
//
//  Created by Kyohei Ito on 2017/11/23.
//  Copyright © 2017年 kyohei_ito. All rights reserved.
//

@objc public protocol KeynodeDelegate {
    /// return false if doesn't need gesture.
    @objc optional func keynode(_ keynode: Keynode, shouldHandlePanningKeyboardAt responder: UIResponder) -> Bool
}
