Keynode
---

![textfield](https://github.com/KyoheiG3/assets/blob/master/Keynode/textfield.gif)![textview](https://github.com/KyoheiG3/assets/blob/master/Keynode/textview.gif)

* change the scroll range at the time of the keyboard display.
* You can perform interactive keyboard display switch.
* You can easily perform the switching of the display to match the height of the keyboard.

## Add to your project
### 1. Add project
Add `Keynode.xcodeproj` to your target.
![add_file](https://github.com/KyoheiG3/assets/blob/master/Keynode/add_file.png)

### 2. Change `iOS Deployment Target`
Should be the same the `iOS Deployment Target` of your target and Keynode of project.
![target_project](https://github.com/KyoheiG3/assets/blob/master/Keynode/target_project.png)
![target_keynode](https://github.com/KyoheiG3/assets/blob/master/Keynode/target_keynode.png)

### 3. Link `Keynode.framework`
![link_libraries](https://github.com/KyoheiG3/assets/blob/master/Keynode/link_libraries.png)

Select `Keynode.framework` in the `Workspace`.
![choose_framework](https://github.com/KyoheiG3/assets/blob/master/Keynode/choose_framework.png)

### 4. Add `Configuration` (Option)
If you are adding a `Configuration` to the target, please manually add the ` Configuration` in the same way also to Keynode.
![configurations](https://github.com/KyoheiG3/assets/blob/master/Keynode/configurations.png)


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
* `view` of target is the initialization of the argument of `Controller`.
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
* Obtain the "inputAccessoryView" of "superview" and has been operating the keyboard, you might not work if the specification has been changed, but it will be addressed in the earliest possible stage.
* `iOS7.0` ~ `iOS8.2` is confirmed operation.
