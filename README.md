# Magnetic

[![Language](https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat)](https://swift.org)
[![Version](https://img.shields.io/cocoapods/v/Magnetic.svg?style=flat)](http://cocoapods.org/pods/Magnetic)
[![License](https://img.shields.io/cocoapods/l/Magnetic.svg?style=flat)](http://cocoapods.org/pods/Magnetic)
[![Platform](https://img.shields.io/cocoapods/p/Magnetic.svg?style=flat)](http://cocoapods.org/pods/Magnetic)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

**Magnetic** is a customizable bubble picker like the Apple Music genre selection.

<img src="https://raw.githubusercontent.com/efremidze/Magnetic/master/Images/demo.gif" width="320">

```
$ pod try Magnetic
```

## Features

- [x] Adding/Removing Nodes
- [x] Selection/Deselection/Removed Animations
- [x] Multiple Selection
- [x] Images
- [x] Multiline Label

## Requirements

- iOS 9.0+
- Xcode 8.0+
- Swift 3.0+

## Usage

A `Magnetic` object is an [SKScene](https://developer.apple.com/reference/spritekit/skscene).

To display, you present it from an [SKView](https://developer.apple.com/reference/spritekit/skview) object.

```swift
import Magnetic

class ViewController: UIViewController {

    var magnetic: Magnetic?
    
    override func loadView() {
        super.loadView()
        
        let magneticView = MagneticView(frame: self.view.bounds)
        magnetic = magneticView.magnetic
        self.view.addSubview(magneticView)
    }

}
```

#### Properties

```swift
var magneticDelegate: MagneticDelegate? // magnetic delegate
var allowsMultipleSelection: Bool // controls whether you can select multiple nodes. defaults to true
var selectedChildren: [Node] // returns selected chidren
```

### Nodes

A `Node` object is a circular SKShapeNode subclass.

#### Interaction

```swift
// add node
func addNode() {
    let node = Node(text: "Italy", image: UIImage(named: "italy"), color: .red, radius: 30)
    magnetic.addChild(node)
}

// remove node
func removeNode() {
    node.removeFromParent()
}
```

#### Properties

```swift
var text: String? // node text
var image: UIImage? // node image
var color: UIColor // node color. defaults to white
```

#### Animations

```swift
override func selectedAnimation() {
    // override selected animation
}

override func deselectedAnimation() {
    // override deselected animation
}

override func removeAnimation(completion: @escaping () -> Void) {
    // override remove animation
}
```

### Delegation

The `MagneticDelegate` protocol provides a number of functions for observing the current state of nodes.

```swift
func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
    // handle node selection
}

func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
    // handle node deselection
}
```

### Customization

Subclass the Node for customization.

For example, a node with an image by default:

```swift
class ImageNode: Node {
    override var image: UIImage? {
        didSet {
            sprite.texture = image.map { SKTexture(image: $0) }
        }
    }
    override func selectedAnimation() {}
    override func deselectedAnimation() {}
}
```

## Installation

### CocoaPods
To install with [CocoaPods](http://cocoapods.org/), simply add this in your `Podfile`:
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
