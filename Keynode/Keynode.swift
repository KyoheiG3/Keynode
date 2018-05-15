//
//  Keynode.swift
//  Keynode
//
//  Created by Kyohei Ito on 2014/11/10.
//  Copyright (c) 2014年 kyohei_ito. All rights reserved.
//

import UIKit

public final class Keynode: NSObject {
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    var isGestureHandlingEnabled: Bool = true
    var firstResponder: Responder?
    weak var targetView: UIView?
    lazy var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(Keynode.panGestureAction(_:)))
    var initialInsetBottom: CGFloat?

    var willAnimateHandler: ((_ show: Bool, _ rect: CGRect) -> Void)?
    var animationsHandler: ((_ show: Bool, _ rect: CGRect) -> Void)?
    var onCompletedHandler: ((_ show: Bool, _ responder: UIResponder?, _ keyboard: UIView?) -> Void)?

    public weak var delegate: KeynodeDelegate?
    /// set false if needn't pan the Keyboard with scrolling gesture. default is true.
    public var isGesturePanningEnabled: Bool = true
    /// set false if needn't change content inset of UIScrollView when opened the Keyboard. default is true.
    public var needsToChangeInsetAutomatically: Bool = true
    public var defaultInsetBottom: CGFloat = 0 {
        didSet {
            if let scrollView = targetView as? UIScrollView {
                scrollView.contentInset.bottom = defaultInsetBottom
                scrollView.scrollIndicatorInsets.bottom = defaultInsetBottom
            }
        }
    }

    public var gestureOffset: CGFloat = 0

    public init(view: UIView) {
        targetView = view
        super.init()
        panGesture.delegate = self

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(Keynode.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(Keynode.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        center.addObserver(self, selector: #selector(Keynode.keyboardDidShow(_:)), name: .UIKeyboardDidShow, object: nil)

        center.addObserver(self, selector: #selector(Keynode.didBecomeFirstResponder(_:)), name: .UIResponderBecomeFirstResponder, object: nil)
    }

    public func setResponder(_ responder: UIResponder) {
        firstResponder = Responder(responder)

        if delegate?.keynode?(self, shouldHandlePanningKeyboardAt: responder) == false {
            isGestureHandlingEnabled = false
        } else {
            isGestureHandlingEnabled = true
        }
    }
}

extension Keynode {
    func willShowAnimation(_ show: Bool, rect: CGRect, duration: TimeInterval, options: UIViewAnimationOptions) {
        var keyboardRect = convert(rect)
        willAnimateHandler?(show, keyboardRect)

        func animations() {
            offsetInsetBottom(keyboardRect.origin.y)
            animationsHandler?(show, keyboardRect)
        }
        func completion(_ finished: Bool) {
            onCompletedHandler?(show, firstResponder?.origin, firstResponder?.keyboard)
        }
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: completion)
    }

    func offsetInsetBottom(_ originY: CGFloat) {
        guard needsToChangeInsetAutomatically, let scrollView = targetView as? UIScrollView else {
            return
        }

        let safeAreaInsetsBottom: CGFloat
        if #available(iOS 11.0, *) {
            safeAreaInsetsBottom = scrollView.safeAreaInsets.bottom
        } else {
            safeAreaInsetsBottom = 0
        }

        if initialInsetBottom == nil {
            initialInsetBottom = scrollView.contentInset.bottom
        }

        let height = max(scrollView.bounds.height - originY, 0)
        let offset = height == 0 ? (initialInsetBottom ?? 0) : -safeAreaInsetsBottom
        scrollView.contentInset.bottom = height + offset + defaultInsetBottom
        scrollView.scrollIndicatorInsets.bottom = height + offset + defaultInsetBottom
    }

    func convert(_ rect: CGRect) -> CGRect {
        guard let window = targetView?.window else {
            return rect
        }

        var rect = window.convert(rect, to: targetView)

        if let scrollView = targetView as? UIScrollView {
            rect.origin.y -= scrollView.contentOffset.y
        }

        return rect
    }

    func changeLocation(_ location: CGPoint, keyboard: UIView, window: UIWindow) {
        let keyboardHeight = keyboard.bounds.size.height
        let windowHeight = window.bounds.size.height
        let thresholdHeight = windowHeight - keyboardHeight

        var keyboardRect = keyboard.frame
        keyboardRect.origin.y = max(min(location.y + gestureOffset, windowHeight), thresholdHeight)

        if keyboardRect.origin.y != keyboard.frame.origin.y {
            let show = keyboardRect.origin.y < keyboard.frame.origin.y
            animationsHandler?(show, keyboardRect)
            Keyboard.shared.frame = keyboardRect
        }
    }

    func changeLocationForAnimation(_ location: CGPoint, velocity: CGPoint, keyboard: UIView, window: UIWindow) {
        let keyboardHeight = keyboard.bounds.size.height
        let windowHeight = window.bounds.size.height
        let thresholdHeight = windowHeight - keyboardHeight
        let show = (location.y + gestureOffset < thresholdHeight || velocity.y < 0)

        var keyboardRect = keyboard.frame
        keyboardRect.origin.y = show ? thresholdHeight : windowHeight

        func animations() {
            offsetInsetBottom(keyboardRect.origin.y)
            animationsHandler?(show, keyboardRect)
            Keyboard.shared.frame = keyboardRect

            if show == false {
                targetView?.removeGestureRecognizer(panGesture)
            }
        }
        func completion(_ finished: Bool) {
            if show == false {
                Keyboard.shared.isHidden = true
                firstResponder?.origin?.resignFirstResponder()
            }
        }

        let info = Info()
        let options = info.curve.union(.beginFromCurrentState)
        UIView.animate(withDuration: info.duration, delay: 0, options: options, animations: animations, completion: completion)
    }
}

// MARK: - Handlers
extension Keynode {
    @discardableResult
    public func willAnimate(_ handler: @escaping (_ show: Bool, _ rect: CGRect) -> Void) -> Keynode {
        willAnimateHandler = handler
        return self
    }

    @discardableResult
    public func animations(_ handler: @escaping (_ show: Bool, _ rect: CGRect) -> Void) -> Keynode {
        animationsHandler = handler
        return self
    }

    @discardableResult
    public func onCompleted(_ handler: @escaping (_ show: Bool, _ responder: UIResponder?, _ keyboard: UIView?) -> Void) -> Keynode {
        onCompletedHandler = handler
        return self
    }
}

// MARK: - Action Methods
extension Keynode {
    @objc func panGestureAction(_ gesture: UIPanGestureRecognizer) {
        guard let keyboard = firstResponder?.keyboard, let window = keyboard.window else {
            return
        }

        if gesture.state == .changed {
            let location = gesture.location(in: window)

            changeLocation(location, keyboard: keyboard, window: window)
        } else if gesture.state == .ended || gesture.state == .cancelled {
            let location = gesture.location(in: window)
            let velocity = gesture.velocity(in: keyboard)

            changeLocationForAnimation(location, velocity: velocity, keyboard: keyboard, window: window)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate Methods
extension Keynode: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == panGesture || otherGestureRecognizer == panGesture
    }
}

// MARK: - NotificationCenter Methods
extension Keynode {
    @objc func didBecomeFirstResponder(_ notification: Notification) {
        if let responder = notification.object as? UIResponder {
            setResponder(responder)
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        UIApplication.shared.needsNotificationFromFirstResponder(self)

        let info = notification.info
        if let rect = info.endFrame {
            willShowAnimation(true, rect: rect, duration: info.duration, options: info.curve.union(.beginFromCurrentState).union(.overrideInheritedDuration))
        }
    }

    @objc func keyboardDidShow(_ notification: Notification) {
        if firstResponder != nil && isGestureHandlingEnabled == true && isGesturePanningEnabled == true {
            targetView?.addGestureRecognizer(panGesture)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        targetView?.removeGestureRecognizer(panGesture)

        let info = notification.info
        if let rect = info.endFrame {
            willShowAnimation(false, rect: rect, duration: info.duration, options: info.curve.union(.overrideInheritedDuration))
        }
    }
}
