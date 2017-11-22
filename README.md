Keynode
---

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/Keynode.svg?style=flat)](http://cocoadocs.org/docsets/Keynode)
[![License](https://img.shields.io/cocoapods/l/Keynode.svg?style=flat)](http://cocoadocs.org/docsets/Keynode)
[![Platform](https://img.shields.io/cocoapods/p/Keynode.svg?style=flat)](http://cocoadocs.org/docsets/Keynode)

#### [Appetize's Demo](https://appetize.io/app/qzmvwjv8m23nn7vkepb9j5bjbw)

* textfield example
<p><img src="https://github.com/KyoheiG3/assets/blob/master/Keynode/textfield.gif" alt="textfield" width="200" /></p>

* textview example
<p><img src="https://github.com/KyoheiG3/assets/blob/master/Keynode/textview.gif" alt="textview" width="200" /></p>

* change the scroll range at the time of the keyboard display.
* You can perform interactive keyboard display switch.
* You can easily perform the switching of the display to match the height of the keyboard.

## Requirements

- Swift 3.0
- iOS 7.0 or later

## How to Install Keynode

### iOS 8+

#### CocoaPods

Add the following to your `Podfile`:

```Ruby
pod "Keynode"
use_frameworks!
```
Note: the `use_frameworks!` is required for pods made in Swift.

#### Carthage

Add the following to your `Cartfile`:

```Ruby
github "KyoheiG3/Keynode"
```

### iOS 7

Just add everything in the `Keynode.swift` file to your project.


## Usage

### import

* import the Keynode.

```Swift
import Keynode
```

### Handler


```Swift
var willAnimationHandler: ((show: Bool, rect: CGRect) -> Void)?
```
* Set the method to be called just before the animation.

```Swift
var animationsHandler: ((show: Bool, rect: CGRect) -> Void)?
```
* Set the method to be called when the display switching animation.
* It is also known at the time of the keyboard operation of the scroll gesture.

```Swift
var completionHandler: ((show: Bool, responder: UIResponder?, keyboard: UIView?) -> Void)?
```
* Set the method to be called at the end animation.

### Variable


```Swift
var gesturePanning: Bool
```
* `true` is lose the keyboard at scroll gesture.
* Default is `true`.

```Swift
var autoScrollInset: Bool
```
* `true` is automatically set the `height` of the `UIScrollView contentInset.bottom` of keyboard when open.
* `view` of target is the initialization of the argument of `Connector`.
* Default is `true`.

```Swift
var defaultInsetBottom: CGFloat
```
* `autoScrollInset` specify the `Inset.bottom` of the case of `true`.
* Default is `0`

```Swift
var gestureOffset: CGFloat
```
* Such as when there is a `toolbar`, you can specify the offset of when closing the keyboard with scroll gesture.
* If the value is not set, the value specified in the `defaultInsetBottom` will be used.

```Swift
// global
let UIResponderFirstResponderNotification: String
```
* Notification name for first responder.

```Swift
// global
let UIResponderFirstResponderUserInfoKey: String
```
* Notification user info key for first responder.


### Function

```swift
func setResponder(responder: UIResponder)
```
* Can set own responder.


### Extension

```swift
// UIApplication
func needNotificationForFirstResponder(from: AnyObject?)
```
* `UIResponderFirstResponderNotification` notification by first responder.

## Caution
* Obtain the `inputAccessoryView` of `superview` and has been operating the keyboard, you might not work if the specification has been changed, but it will be addressed in the earliest possible stage.
* `iOS7.0` ~ `iOS11.0` is confirmed operation.

## Acknowledgements

* Inspired by [DAKeyboardControl](https://github.com/danielamitay/DAKeyboardControl) in [danielamitay](https://github.com/danielamitay).

## LICENSE
Under the MIT license. See LICENSE file for details.
