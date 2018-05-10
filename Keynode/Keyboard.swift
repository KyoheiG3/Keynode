//
//  Keyboard.swift
//  Keynode
//
//  Created by Kyohei Ito on 2017/11/23.
//  Copyright © 2017年 kyohei_ito. All rights reserved.
//

final class Keyboard {
    static let shared = Keyboard()
    var origin: UIView? {
        return remoteKeyboard
    }

    private weak var remoteKeyboard: UIView?
    private weak var effectsKeyboard: UIView?

    var frame: CGRect? {
        get {
            return origin?.frame
        }
        set {
            if let frame = newValue {
                remoteKeyboard?.frame = frame
                effectsKeyboard?.frame = frame
            }
        }
    }

    var isHidden: Bool? {
        get {
            return origin?.isHidden
        }
        set {
            if let isHidden = newValue {
                remoteKeyboard?.isHidden = isHidden
                effectsKeyboard?.isHidden = isHidden
            }
        }
    }

    func setKeyboard(_ newValue: UIView?) {
        if let view = newValue, effectsKeyboard != view {
            effectsKeyboard = view
        }

        let application = UIApplication.shared
        remoteKeyboard = application.windows
            .filter { "\(type(of: $0))" == "UIRemoteKeyboardWindow" }
            .first?.subviews.first?.subviews.first
    }
}

