//
//  Keynode.swift
//  Keynode
//
//  Created by Kyohei Ito on 2014/11/10.
//  Copyright (c) 2014年 kyohei_ito. All rights reserved.
//

import UIKit

@objc public protocol ConnectorDelegate {
    /**
     * return false if need be not gesture.
     */
    @objc optional func connector(_ connector: Keynode.Connector, shouldHandlePanningKeyboardAtResponder responder: UIResponder) -> Bool
}

open class Keynode {
    private static var connector: Connector? = {
        let connector = Connector(instance: ())
        connector.workingTextField = UITextField()
        connector.workingTextField?.becomeFirstResponder()
        return connector
    }()
    @objc(KeynodeConnector)
    open class Connector: NSObject {
        fileprivate init(instance: Void) {
            super.init()
            let center = NotificationCenter.default
            center.addObserver(self, selector: #selector(Connector.keyboardDidShow(_:)), name: .UIKeyboardDidShow, object: nil)
            center.addObserver(self, selector: #selector(Connector.keyboardDidHide(_:)), name: .UIKeyboardDidHide, object: nil)
            workingInstance = self
        }
        fileprivate var workingInstance: Connector?
        fileprivate var workingTextField: UITextField? {
            didSet {
                if let textField = workingTextField {
                    textField.inputAccessoryView = UIView()
                    textField.inputView = UIView()
                    
                    if let window = UIApplication.shared.windows.first {
                        window.addSubview(textField)
                    }
                }
            }
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        fileprivate var gestureHandle: Bool = true
        fileprivate var firstResponder: Responder?
        fileprivate weak var targetView: UIView?
        fileprivate lazy var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(Connector.panGestureAction(_:)))
        
        open var willAnimationHandler: ((_ show: Bool, _ rect: CGRect) -> Void)?
        open var animationsHandler: ((_ show: Bool, _ rect: CGRect) -> Void)?
        open var completionHandler: ((_ show: Bool, _ responder: UIResponder?, _ keyboard: UIView?) -> Void)?
        
        open weak var delegate: ConnectorDelegate?
        /// `true` is lose the keyboard at scroll gesture.
        open var gesturePanning: Bool = true
        /// `true` is automatically set the height of the UIScrollView contentInset.bottom of keyboard when open.
        open var autoScrollInset: Bool = true
        open var defaultInsetBottom: CGFloat = 0 {
            didSet {
                if let scrollView = targetView as? UIScrollView {
                    scrollView.contentInset.bottom = defaultInsetBottom
                    scrollView.scrollIndicatorInsets.bottom = defaultInsetBottom
                }
            }
        }
        
        open lazy var gestureOffset: CGFloat = self.defaultInsetBottom
        
        public init(view: UIView? = nil) {
            connector = nil // referencing of initialize for keyboard.
            targetView = view
            super.init()
            
            let center = NotificationCenter.default
            
            if view != nil {
                panGesture.delegate = self
                
                center.addObserver(self, selector: #selector(Connector.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                center.addObserver(self, selector: #selector(Connector.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
                
                center.addObserver(self, selector: #selector(Connector.textDidBeginEditing(_:)), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: nil)
                center.addObserver(self, selector: #selector(Connector.textDidBeginEditing(_:)), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
                
                center.addObserver(self, selector: #selector(Connector.didBecomeFirstResponder(_:)), name: NSNotification.Name(rawValue: UIResponderFirstResponderNotification), object: nil)
            }
            
            center.addObserver(self, selector: #selector(Connector.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
            center.addObserver(self, selector: #selector(Connector.keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        }
        
        /// Can set own responder.
        open func setResponder(_ responder: UIResponder) {
            firstResponder = Responder(responder)
            if checkWork(workingTextField) {
                return
            }
            
            if delegate?.connector?(self, shouldHandlePanningKeyboardAtResponder: responder) == false {
                gestureHandle = false
            } else {
                gestureHandle = true
            }
        }
    }
}

private extension Keynode {
    class Keyboard {
        static let sharedInstance = Keyboard()
        static var sharedKeyboard: UIView? {
            return sharedInstance.remoteKeyboard
        }
        
        fileprivate weak var remoteKeyboard: UIView?
        fileprivate weak var effectsKeyboard: UIView?
        
        static var frame: CGRect? {
            get {
                return sharedKeyboard?.frame
            }
            set {
                if let frame = newValue {
                    sharedInstance.remoteKeyboard?.frame = frame
                    sharedInstance.effectsKeyboard?.frame = frame
                }
            }
        }
        
        static var hidden: Bool? {
            get {
                return sharedKeyboard?.isHidden
            }
            set {
                if let hidden = newValue {
                    sharedInstance.remoteKeyboard?.isHidden = hidden
                    sharedInstance.effectsKeyboard?.isHidden = hidden
                }
            }
        }
        
        class func setKeyboard(_ newValue: UIView?) {
            func getKeyboard(_ keyboard: UIView) -> UIView {
                let application = UIApplication.shared
                
                if let remoteKeyboard = application.windows.reduce([], { acc, window -> [UIView] in
                    guard window != keyboard.window && window != application.keyWindow, let controller = window.rootViewController else {
                        return acc
                    }
                    
                    return acc + controller.view.subviews.filter({ (view: UIView) in
                        return type(of: view) == type(of: keyboard)
                    })
                }).first {
                    return remoteKeyboard
                } else {
                    return keyboard
                }
            }
            
            if let view = newValue , sharedInstance.effectsKeyboard != view {
                sharedInstance.effectsKeyboard = view
            }
            
            if let Keyboard = sharedInstance.effectsKeyboard {
                sharedInstance.remoteKeyboard = getKeyboard(Keyboard)
            }
        }
    }
}

private extension Keynode {
    class Responder {
        fileprivate weak var responder: UIResponder?
        fileprivate var blankAccessoryView = UIView()
        
        var inputAccessoryView: UIView? {
            get {
                return responder?.inputAccessoryView
            }
            set {
                if newValue == nil {
                    return
                }
                
                if let textView = responder as? UITextView {
                    textView.inputAccessoryView = newValue
                } else if let textField = responder as? UITextField {
                    textField.inputAccessoryView = newValue
                }
            }
        }
        
        var keyboard: UIView? {
            Keynode.Keyboard.setKeyboard(inputAccessoryView?.superview)
            
            return Keynode.Keyboard.sharedKeyboard
        }
        
        init(_ responder: UIResponder) {
            self.responder = responder
            
            if inputAccessoryView == nil {
                inputAccessoryView = blankAccessoryView
            } else {
                Keyboard.setKeyboard(inputAccessoryView?.superview)
            }
        }
        
        deinit {
            if inputAccessoryView == blankAccessoryView {
                inputAccessoryView = nil
            }
            Keyboard.hidden = false
        }
    }
}

private extension Keynode {
    class Info {
        fileprivate let AnimationDuration: TimeInterval = 0.25
        fileprivate let AnimationCurve: UInt = 7
        fileprivate var userInfo: [AnyHashable: Any]?
        
        init(_ userInfo: [AnyHashable: Any]? = nil) {
            self.userInfo = userInfo
        }
        
        var duration: TimeInterval {
            if let duration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
                return duration
            }
            return AnimationDuration
        }
        
        var curve: UIViewAnimationOptions {
            if let curve = userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
                return animationOptionsForAnimationCurve(curve)
            }
            return animationOptionsForAnimationCurve(AnimationCurve)
        }
        
        var beginFrame: CGRect? {
            return userInfoRect(UIKeyboardFrameBeginUserInfoKey)
        }
        
        var endFrame: CGRect? {
            return userInfoRect(UIKeyboardFrameEndUserInfoKey)
        }
        
        fileprivate func userInfoRect(_ infoKey: String) -> CGRect? {
            let frame = (userInfo?[infoKey] as? NSValue)?.cgRectValue
            if let rect = frame {
                if rect.origin.x.isInfinite || rect.origin.y.isInfinite {
                    return nil
                }
            }
            return frame
        }
        
        func animationOptionsForAnimationCurve(_ curve: UInt) -> UIViewAnimationOptions {
            return UIViewAnimationOptions(rawValue: curve << 16)
        }
    }
}

private extension Keynode.Connector {
    func willShowAnimation(_ show: Bool, rect: CGRect, duration: TimeInterval, options: UIViewAnimationOptions) {
        var keyboardRect = convertKeyboardRect(rect)
        willAnimationHandler?(show, keyboardRect)
        
        func animations() {
            offsetInsetBottom(keyboardRect.origin.y)
            animationsHandler?(show, keyboardRect)
        }
        func completion(_ finished: Bool) {
            completionHandler?(show, firstResponder?.responder, firstResponder?.keyboard)
        }
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: completion)
    }
    
    func offsetInsetBottom(_ originY: CGFloat) {
        guard autoScrollInset, let scrollView = targetView as? UIScrollView else {
            return
        }
        
        let height = max(scrollView.bounds.height - originY, 0)
        scrollView.contentInset.bottom = height + defaultInsetBottom
        scrollView.scrollIndicatorInsets.bottom = height + defaultInsetBottom
    }
    
    func convertKeyboardRect(_ rect: CGRect) -> CGRect {
        var rect = rect
        guard let window = targetView?.window else {
            return rect
        }
        
        rect = window.convert(rect, to: targetView)
        
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
        keyboardRect.origin.y = min(location.y + gestureOffset, windowHeight)
        keyboardRect.origin.y = max(keyboardRect.origin.y, thresholdHeight)
        
        if keyboardRect.origin.y != keyboard.frame.origin.y {
            let show = keyboardRect.origin.y < keyboard.frame.origin.y
            animationsHandler?(show, keyboardRect)
            Keynode.Keyboard.frame = keyboardRect
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
            Keynode.Keyboard.frame = keyboardRect
            
            if show == false {
                targetView?.removeGestureRecognizer(panGesture)
            }
        }
        func completion(_ finished: Bool) {
            if show == false {
                Keynode.Keyboard.hidden = true
                firstResponder?.responder?.resignFirstResponder()
            }
        }
        
        let info = Keynode.Info()
        let options = info.curve.union(.beginFromCurrentState)
        UIView.animate(withDuration: info.duration, delay: 0, options: options, animations: animations, completion: completion)
    }
    
    func checkWork(_ responder: UIResponder?) -> Bool {
        if let responder = responder {
            if responder == firstResponder?.responder {
                return true
            }
        }
        return false
    }
}

// MARK: - Action Methods
extension Keynode.Connector {
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
extension Keynode.Connector: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == panGesture || otherGestureRecognizer == panGesture
    }
}

// MARK: - NSNotificationCenter Methods
extension Keynode.Connector {
    @objc func textDidBeginEditing(_ notification: Notification) {
        if let responder = notification.object as? UIResponder {
            setResponder(responder)
        }
    }
    
    @objc func didBecomeFirstResponder(_ notification: Notification) {
        if let responder = (notification as NSNotification).userInfo?[UIResponderFirstResponderUserInfoKey] as? UIResponder
            , !(responder is UITextView) && !(responder is UITextField) {
            setResponder(responder)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if checkWork(workingTextField) {
            return
        }
        
        UIApplication.shared.needNotificationForFirstResponder(self)
        
        let info = Keynode.Info((notification as NSNotification).userInfo)
        
        if let rect = info.endFrame {
            willShowAnimation(true, rect: rect, duration: info.duration, options: info.curve.union(.beginFromCurrentState).union(.overrideInheritedDuration))
        }
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        if checkWork(workingTextField) {
            return
        }
        
        if let textField = workingTextField {
            workingTextField = nil
            let _ = Keynode.Responder(textField)
            textField.resignFirstResponder()
            textField.removeFromSuperview()
            return
        }
        
        if firstResponder != nil {
            if gestureHandle == true && gesturePanning == true {
                targetView?.addGestureRecognizer(panGesture)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if checkWork(workingTextField) {
            return
        }
        
        targetView?.removeGestureRecognizer(panGesture)
        
        let info = Keynode.Info((notification as NSNotification).userInfo)
        
        if let rect = info.endFrame {
            willShowAnimation(false, rect: rect, duration: info.duration, options: info.curve.union(.overrideInheritedDuration))
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        workingInstance = nil
    }
}

internal extension UIResponder {
    class var FirstResponderNotificationAction: Selector {
        return #selector(UIResponder.firstResponderNotification(_:))
    }
    
    @objc func firstResponderNotification(_ sender: AnyObject?) {
        let userInfo = [UIResponderFirstResponderUserInfoKey: self]
        NotificationCenter.default.post(name: Notification.Name(rawValue: UIResponderFirstResponderNotification), object: sender, userInfo: userInfo)
    }
}

public extension UIApplication {
    /// `UIResponderFirstResponderNotification` notification by first responder
    public func needNotificationForFirstResponder(_ from: AnyObject?) {
        sendAction(UIResponder.FirstResponderNotificationAction, to: nil, from: from, for: nil)
    }
}

/// first responder notification name
public let UIResponderFirstResponderNotification = "UIResponderFirstResponderNotification"

/// first responder user info key
public let UIResponderFirstResponderUserInfoKey = "UIResponderFirstResponderUserInfoKey"
