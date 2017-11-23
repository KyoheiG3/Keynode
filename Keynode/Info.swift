//
//  Info.swift
//  Keynode
//
//  Created by Kyohei Ito on 2017/11/23.
//  Copyright © 2017年 kyohei_ito. All rights reserved.
//

struct Info {
    private let animationDuration: TimeInterval = 0.25
    private let animationCurve: UInt = 7
    private var userInfo: [AnyHashable: Any]?

    init(userInfo: [AnyHashable: Any]? = nil) {
        self.userInfo = userInfo
    }

    var duration: TimeInterval {
        if let duration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            return duration
        }
        return animationDuration
    }

    var curve: UIViewAnimationOptions {
        if let curve = userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
            return animationOptions(for: curve)
        }
        return animationOptions(for: animationCurve)
    }

    var beginFrame: CGRect? {
        return userInfoRect(UIKeyboardFrameBeginUserInfoKey)
    }

    var endFrame: CGRect? {
        return userInfoRect(UIKeyboardFrameEndUserInfoKey)
    }

    private func userInfoRect(_ infoKey: String) -> CGRect? {
        let frame = (userInfo?[infoKey] as? NSValue)?.cgRectValue
        if let rect = frame, rect.origin.x.isInfinite || rect.origin.y.isInfinite {
            return nil
        }
        return frame
    }

    private func animationOptions(for animationCurve: UInt) -> UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: animationCurve << 16)
    }
}

