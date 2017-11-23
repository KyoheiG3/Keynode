//
//  Responder.swift
//  Keynode
//
//  Created by Kyohei Ito on 2017/11/23.
//  Copyright © 2017年 kyohei_ito. All rights reserved.
//

final class Responder {
    weak var origin: UIResponder?
    private let blankView = UIView()
    private var accessoryView: UIView? {
        get {
            return origin?.inputAccessoryView
        }
        set {
            (origin as? InputAccessoryType)?.inputAccessoryView = newValue
        }
    }

    var keyboard: UIView? {
        Keyboard.shared.setKeyboard(accessoryView?.superview)

        return Keyboard.shared.origin
    }

    init(_ responder: UIResponder) {
        self.origin = responder

        if accessoryView == nil {
            accessoryView = blankView
        } else {
            Keyboard.shared.setKeyboard(accessoryView?.superview)
        }
    }

    deinit {
        if accessoryView == blankView {
            accessoryView = nil
        }
        Keyboard.shared.isHidden = false
    }
}
