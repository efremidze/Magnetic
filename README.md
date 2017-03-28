# Magnetic

[![Language](https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat)](https://swift.org)
[![Version](https://img.shields.io/cocoapods/v/Magnetic.svg?style=flat)](http://cocoapods.org/pods/Magnetic)
[![License](https://img.shields.io/cocoapods/l/Magnetic.svg?style=flat)](http://cocoapods.org/pods/Magnetic)
[![Platform](https://img.shields.io/cocoapods/p/Magnetic.svg?style=flat)](http://cocoapods.org/pods/Magnetic)

**Magnetic** is a customizable bubble picker like the Apple Music genre selection.

![Demo](Images/demo.gif)

```
$ pod try Magnetic
```

## Requirements

- iOS 9.3+
- Xcode 8.0+
- Swift 3.0+

## Usage

A `Magnetic` object is an [SKScene](https://developer.apple.com/reference/spritekit/skscene).

To display, you present it from an [SKView](https://developer.apple.com/reference/spritekit/skview) object.

```swift
import Magnetic

class ViewController: UIViewController {

    var skView: SKView {
        return view as! SKView
    }

    override func loadView() {
        super.loadView()

        self.view = SKView(frame: self.view.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = Magnetic(size: self.view.bounds.size)
        skView.presentScene(scene)
    }

}
```

#### Add Nodes

```swift
func addNode() {
    let node = Node(title: "Italy", image: UIImage(named: "italy"), color: .red, radius: 30)
    scene.addChild(node)
}
```

#### Remove Nodes

```swift
func removeNode() {
    node.removeFromParent()
}
```

## Installation

### CocoaPods
To install with [CocoaPods](http://cocoapods.org/), simply add the following line to your `Podfile`:
```ruby
use_frameworks!
pod "Magnetic"
```

### Carthage
To install with [Carthage](https://github.com/Carthage/Carthage), simply add this in your `Cartfile`:
```ruby
github "efremidze/Magnetic"
```

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Credits

https://github.com/igalata/Bubble-Picker

## License

Magnetic is available under the MIT license. See the LICENSE file for more info.
