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
    optional func connector(connector: Keynode.Connector, shouldHandlePanningKeyboardAtResponder responder: UIResponder) -> Bool
}

public class Keynode {
    @objc(KeynodeConnector)
    public class Connector: NSObject {
        private struct Singleton {
            static var instance: UITextField? {
                didSet {
                    if let textField = instance {
                        
                        textField.inputAccessoryView = UIView()
                        textField.inputView = UIView()
                        
                        if let window = UIApplication.sharedApplication().windows.first as? UIWindow {
                            window.addSubview(textField)
                        }
                    }
                }
            }
        }
        
        private var workingInstance: Connector?
        private var workingTextField: UITextField? {
            set {
                Singleton.instance = newValue
            }
            get {
                return Singleton.instance
            }
        }
        
        public override class func initialize() {
            super.initialize()
            
            if self.isEqual(Connector.self) {
                let connector = Connector()
                connector.workingInstance = connector
                
                connector.workingTextField = UITextField()
                
                dispatch_async(dispatch_get_main_queue()) {
                    connector.workingTextField?.becomeFirstResponder()
                    return
                }
            }
        }
        
        deinit {
            workingTextField = nil
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        
        private var gestureHandle: Bool = true
        private var firstResponder: Responder?
        private weak var targetView: UIView?
        private lazy var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panGestureAction:")
        
        public var willAnimationHandler: ((show: Bool, rect: CGRect) -> Void)?
        public var animationsHandler: ((show: Bool, rect: CGRect) -> Void)?
        public var completionHandler: ((show: Bool, responder: UIResponder?, keyboard: UIView?) -> Void)?
        
        public weak var delegate: ConnectorDelegate?
        public var gesturePanning: Bool = true
        public var autoScrollInset: Bool = true
        public var defaultInsetBottom: CGFloat = 0 {
            didSet {
                if let scrollView = targetView as? UIScrollView {
                    scrollView.contentInset.bottom = defaultInsetBottom
                }
            }
        }
        
        private var _gestureOffset: CGFloat?
        public var gestureOffset: CGFloat {
            set {
                _gestureOffset = newValue
            }
            get {
                if let offset = _gestureOffset {
                    return offset
                }
                return defaultInsetBottom
            }
        }
        
        public init(view: UIView? = nil) {
            self.targetView = view
            super.init()
            
            let center = NSNotificationCenter.defaultCenter()
            
            if view != nil {
                panGesture.delegate = self
                
                center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
                center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
                
                center.addObserver(self, selector: "textDidBeginEditing:", name: UITextFieldTextDidBeginEditingNotification, object: nil)
                center.addObserver(self, selector: "textDidBeginEditing:", name: UITextViewTextDidBeginEditingNotification, object: nil)
            }
            
            center.addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
            center.addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
        }
        
        public func setResponder(responder: UIResponder) {
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
        weak var view: UIView?
        struct Singleton {
            static let instance = Keyboard()
        }
        
        class func sharedKeyboard() -> UIView? {
            return Singleton.instance.view
        }
        
        class func setKeyboard(newValue: UIView?) {
            if let view = newValue {
                if Singleton.instance.view != view {
                    Singleton.instance.view = view
                }
            }
        }
    }
}

private extension Keynode {
    class Responder {
        private weak var responder: UIResponder?
        private var blankAccessoryView = UIView()
        
        var inputAccessoryView: UIView? {
            set {
                if let textView = responder as? UITextView {
                    textView.inputAccessoryView = newValue
                } else if let textField = responder as? UITextField {
                    textField.inputAccessoryView = newValue
                }
            }
            get {
                return responder?.inputAccessoryView
            }
        }
        
        var keyboard: UIView? {
            Keynode.Keyboard.setKeyboard(inputAccessoryView?.superview)
            
            return Keynode.Keyboard.sharedKeyboard()
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
            keyboard?.hidden = false
        }
    }
}

private extension Keynode {
    class Info {
        private let AnimationDuration: NSTimeInterval = 0.25
        private let AnimationCurve: UInt = 7
        private var userInfo: [NSObject : AnyObject]?
        
        init(_ userInfo: [NSObject : AnyObject]? = nil) {
            self.userInfo = userInfo
        }
        
        var duration: NSTimeInterval {
            if let duration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval {
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
        
        var frame: CGRect? {
            let frame = userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
            if let rect = frame {
                if rect.origin.x.isInfinite || rect.origin.y.isInfinite {
                    return nil
                }
            }
            return frame
        }
        
        func animationOptionsForAnimationCurve(curve: UInt) -> UIViewAnimationOptions {
            return UIViewAnimationOptions(curve << 16)
        }
    }
}

private extension Keynode.Connector {
    func willShowAnimation(show: Bool, rect: CGRect, duration: NSTimeInterval, options: UIViewAnimationOptions) {
        var keyboardRect = convertKeyboardRect(rect)
        willAnimationHandler?(show: show, rect: keyboardRect)
        
        func animations() {
            offsetInsetBottom(keyboardRect.origin.y)
            animationsHandler?(show: show, rect: keyboardRect)
        }
        func completion(finished: Bool) {
            completionHandler?(show: show, responder: firstResponder?.responder, keyboard: firstResponder?.keyboard)
        }
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: animations, completion: completion)
    }
    
    func offsetInsetBottom(originY: CGFloat) {
        if autoScrollInset == false {
            return
        }
        
        if let scrollView = targetView as? UIScrollView {
            let height = max(scrollView.bounds.height - originY, 0)
            scrollView.contentInset.bottom = height + defaultInsetBottom
        }
    }
    
    func convertKeyboardRect(var rect: CGRect) -> CGRect {
        if let window = targetView?.window {
            rect = window.convertRect(rect, toView: targetView)
            
            if let scrollView = targetView as? UIScrollView {
                rect.origin.y -= scrollView.contentOffset.y
            }
        }
        return rect
    }
    
    func changeLocation(location: CGPoint, keyboard: UIView, window: UIWindow) {
        let keyboardHeight = keyboard.bounds.size.height
        let windowHeight = window.bounds.size.height
        let thresholdHeight = windowHeight - keyboardHeight
        
        var keyboardRect = keyboard.frame
        keyboardRect.origin.y = min(location.y + gestureOffset, windowHeight)
        keyboardRect.origin.y = max(keyboardRect.origin.y, thresholdHeight)
        
        if keyboardRect.origin.y != keyboard.frame.origin.y {
            let show = keyboardRect.origin.y < keyboard.frame.origin.y
            animationsHandler?(show: show, rect: keyboardRect)
            keyboard.frame = keyboardRect
        }
    }
    
    func changeLocationForAnimation(location: CGPoint, velocity: CGPoint, keyboard: UIView, window: UIWindow) {
        let keyboardHeight = keyboard.bounds.size.height
        let windowHeight = window.bounds.size.height
        let thresholdHeight = windowHeight - keyboardHeight
        let show = (location.y + gestureOffset < thresholdHeight || velocity.y < 0)
        
        var keyboardRect = keyboard.frame
        keyboardRect.origin.y = show ? thresholdHeight : windowHeight
        
        func animations() {
            offsetInsetBottom(keyboardRect.origin.y)
            animationsHandler?(show: show, rect: keyboardRect)
            keyboard.frame = keyboardRect
            
            if show == false {
                targetView?.removeGestureRecognizer(panGesture)
            }
        }
        func completion(finished: Bool) {
            if show == false {
                keyboard.hidden = true
                firstResponder?.responder?.resignFirstResponder()
            }
        }
        
        let info = Keynode.Info()
        let options = info.curve | .BeginFromCurrentState
        UIView.animateWithDuration(info.duration, delay: 0, options: options, animations: animations, completion: completion)
    }
    
    func checkWork(responder: UIResponder?) -> Bool {
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
    func panGestureAction(gesture: UIPanGestureRecognizer) {
        if let keyboard = firstResponder?.keyboard {
            if let window = keyboard.window {
                if gesture.state == .Changed {
                    let location = gesture.locationInView(window)
                    
                    changeLocation(location, keyboard: keyboard, window: window)
                } else if gesture.state == .Ended || gesture.state == .Cancelled {
                    let location = gesture.locationInView(window)
                    let velocity = gesture.velocityInView(keyboard)
                    
                    changeLocationForAnimation(location, velocity: velocity, keyboard: keyboard, window: window)
                }
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate Methods
extension Keynode.Connector: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == panGesture || otherGestureRecognizer == panGesture
    }
}

// MARK: - NSNotificationCenter Methods
extension Keynode.Connector {
    func textDidBeginEditing(notification: NSNotification) {
        if let responder = notification.object as? UIResponder {
            setResponder(responder)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if checkWork(workingTextField) {
            return
        }
        
        let info = Keynode.Info(notification.userInfo)
        
        if let rect = info.frame {
            willShowAnimation(true, rect: rect, duration: info.duration, options: info.curve | .BeginFromCurrentState)
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if checkWork(workingTextField) {
            return
        }
        
        if let textField = workingTextField {
            Keynode.Responder(textField)
            textField.resignFirstResponder()
            textField.removeFromSuperview()
            return
        }
        
        if let responder = firstResponder {
            if gestureHandle == true && gesturePanning == true {
                targetView?.addGestureRecognizer(panGesture)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if checkWork(workingTextField) {
            return
        }
        
        targetView?.removeGestureRecognizer(panGesture)
        
        let info = Keynode.Info(notification.userInfo)
        
        if let rect = info.frame {
            willShowAnimation(false, rect: rect, duration: info.duration, options: info.curve | .BeginFromCurrentState)
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
        workingInstance = nil
    }
}
