Keynode
---

[![Carthage Compatibility](https://img.shields.io/badge/carthage-✓-f2a77e.svg?style=flat)](https://github.com/Carthage/Carthage/)
[![Version](https://img.shields.io/cocoapods/v/Keynode.svg?style=flat)](http://cocoadocs.org/docsets/Keynode)
[![License](https://img.shields.io/cocoapods/l/Keynode.svg?style=flat)](http://cocoadocs.org/docsets/Keynode)
[![Platform](https://img.shields.io/cocoapods/p/Keynode.svg?style=flat)](http://cocoadocs.org/docsets/Keynode)

* textfield example
<p><img src="https://github.com/KyoheiG3/assets/blob/master/Keynode/textfield.gif" alt="textfield" width="200" /></p>

* textview example
<p><img src="https://github.com/KyoheiG3/assets/blob/master/Keynode/textview.gif" alt="textview" width="200" /></p>

* change the scroll range at the time of the keyboard display.
* You can perform interactive keyboard display switch.
* You can easily perform the switching of the display to match the height of the keyboard.

## Add to your project

### 1. Add project
Add `Keynode.xcodeproj` to your target.
<p><img src="https://github.com/KyoheiG3/assets/blob/master/Keynode/add_file.png" alt="add_file" width="400" /></p>

### 2. Add Embedded Binaries `Keynode.framework`
<p><img src="https://github.com/KyoheiG3/assets/blob/master/Keynode/add_embedded.png" alt="add_embedded" width="400" /></p>

Select `Keynode.framework` in the `Workspace`.
<p><img src="https://github.com/KyoheiG3/assets/blob/master/Keynode/choose_framework.png" alt="choose_framework" width="200" /></p>

### 3. Add `Configuration` (Option)
If you are adding a `Configuration` to the target, please manually add the ` Configuration` in the same way also to Keynode.
<p><img src="https://github.com/KyoheiG3/assets/blob/master/Keynode/configurations.png" alt="configurations" width="400" /></p>

## Add to your project (iOS7.1 and earlier)

### 1. Add source

Add `Keynode.swift`.
<p><img src="https://github.com/KyoheiG3/assets/blob/master/Keynode/add_source.png" alt="add_source" width="400" /></p>


## How to Install Keynode using Beta CocoaPods

You need to install the beta build of CocoaPods via `[sudo] gem install cocoapods --pre` then add Keynode to your Podfile.

```
  pod 'Keynode'
```

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
* Set of whether or not to close the keyboard with scroll gesture.
* Default is `true`

```Swift
var autoScrollInset: Bool
```
* In the case of a subclass of the target `view` is` UIScrollView`, you can specify whether the keyboard is automatically set the height of the `contentInset.bottom` of keyboard when open.
* `view` of target is the initialization of the argument of `Connector`.
* Default is `true`

```Swift
var defaultInsetBottom: CGFloat
```
* `autoScrollInset` specify the `Inset.bottom` of the case of `true`.
* Default is `0`

```Swift
var gestureOffset: CGFloat
```
* Such as when there is a toolbar, you can specify the offset of when closing the keyboard with scroll gesture.
* If the value is not set, the value specified in the `defaultInsetBottom` will be used.

## Caution
* Obtain the `inputAccessoryView` of `superview` and has been operating the keyboard, you might not work if the specification has been changed, but it will be addressed in the earliest possible stage.
* `iOS7.0` ~ `iOS8.2` is confirmed operation.

## Thanks
* Inspired by DAKeyboardControl in [danielamitay](https://github.com/danielamitay).

## LICENSE
Under the MIT license. See LICENSE file for details.