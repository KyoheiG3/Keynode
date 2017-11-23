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

        if let effects = effectsKeyboard {
            let application = UIApplication.shared
            let remote = application.windows
                .filter { $0 != effects.window && $0 != application.keyWindow }
                .flatMap { $0.rootViewController?.view.subviews }
                .flatMap { $0 }
                .filter { type(of: $0) == type(of: effects) }
                .first
            remoteKeyboard = remote ?? effects
        }
    }
}

