# Keynode

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/Keynode.svg?style=flat)](http://cocoadocs.org/docsets/Keynode)
[![License](https://img.shields.io/cocoapods/l/Keynode.svg?style=flat)](http://cocoadocs.org/docsets/Keynode)
[![Platform](https://img.shields.io/cocoapods/p/Keynode.svg?style=flat)](http://cocoadocs.org/docsets/Keynode)

## Why

Using `UIScrollViewKeyboardDismissMode` added in iOS7, interactive keyboard operation became possible. But, it only works on `UIScrollView`.

`Keynode` is able to interactive operate all `inputView` that appear as `FirstResponder`.

#### [Appetize's Demo](https://appetize.io/app/qzmvwjv8m23nn7vkepb9j5bjbw)

| `UITextField` | `UITextField` | `UIPickerView` |
|-|-|-|
|<img alt="UIPickerView" src="https://user-images.githubusercontent.com/5707132/33164588-d533510c-d076-11e7-9cad-75984f336758.gif" width="200">|<img alt="UITextField" src="https://user-images.githubusercontent.com/5707132/33164594-da5148ce-d076-11e7-93ec-54ae5ffef90e.gif" width="200">|<img alt="UITextField" src="https://user-images.githubusercontent.com/5707132/33164597-dc536c56-d076-11e7-8691-77a469f387fe.gif" width="200">|

## Requirements

- Swift 4.1
- iOS 9.0 or later

## How to Install

#### CocoaPods

Add the following to your `Podfile`:

```Ruby
pod "Keynode"
```

#### Carthage

Add the following to your `Cartfile`:

```Ruby
github "KyoheiG3/Keynode"
```

## Usage

### Function

```Swift
func willAnimate(_ handler: @escaping (Bool, CGRect) -> Swift.Void) -> Keynode.Keynode
```

- To be called just before the animation.

```Swift
func animations(_ handler: @escaping (Bool, CGRect) -> Swift.Void) -> Keynode.Keynode
```

- To be called when the display switching animation.
- It is also called at the time of the keyboard operation of the scroll gesture.

```Swift
func onCompleted(_ handler: @escaping (Bool, UIResponder?, UIView?) -> Swift.Void) -> Keynode.Keynode
```

- To be called at the end animation.

```swift
func setResponder(responder: UIResponder)
```

- Can set the responder.

### Variable

```Swift
var isGesturePanningEnabled: Bool
```

- Set `false` if needn't pan the Keyboard with scrolling gesture.
- Default is `true`.

```Swift
var needsToChangeInsetAutomatically: Bool
```

- Set `false` if needn't change content inset of `UIScrollView` when opened the Keyboard.
- Default is `true`.

```Swift
var defaultInsetBottom: CGFloat
```

- Change bottom of `contentInset` if needed.
- Default is `0`

```Swift
var gestureOffset: CGFloat
```

- Such as when there is a `toolbar`, you can specify the offset of when closing the keyboard with scroll gesture.
- If the value is not set, the value specified in the `defaultInsetBottom` will be used.

### Extension

```Swift
extension NSNotification.Name {
    static let UIResponderBecomeFirstResponder: Notification.Name
}
```

- Notification name for become first responder.

```Swift
extension UIApplication {
    func needsNotificationFromFirstResponder(_ from: Swift.AnyObject?)
}
```

- Receive the notification from first responder when the function executed.

## Caution

- It might not work if the specification has been changed. however it will be solved in the earliest possible stage.
- `iOS9.0` ~ `iOS11.3` is confirmed operation.

## Acknowledgements

- Inspired by [DAKeyboardControl](https://github.com/danielamitay/DAKeyboardControl) in [danielamitay](https://github.com/danielamitay).

## Author

#### Kyohei Ito

- [GitHub](https://github.com/kyoheig3)
- [Twitter](https://twitter.com/kyoheig3)

Follow me 🎉

## LICENSE
Under the MIT license. See LICENSE file for details.
