# Magnetic

[![Build Status](https://travis-ci.org/efremidze/Magnetic.svg?branch=master)](https://travis-ci.org/efremidze/Magnetic)
[![Language](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://swift.org)
[![Version](https://img.shields.io/cocoapods/v/Magnetic.svg?style=flat)](http://cocoapods.org/pods/Magnetic)
[![License](https://img.shields.io/cocoapods/l/Magnetic.svg?style=flat)](http://cocoapods.org/pods/Magnetic)
[![Platform](https://img.shields.io/cocoapods/p/Magnetic.svg?style=flat)](http://cocoapods.org/pods/Magnetic)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

**Magnetic** is a customizable bubble picker like the Apple Music genre selection.

![Demo GIF](https://thumbs.gfycat.com/RelievedHardAmericanpainthorse-size_restricted.gif)

[Demo Video](https://gfycat.com/RelievedHardAmericanpainthorse)

```
$ pod try Magnetic
```

## Features

- [x] Adding/Removing Nodes
- [x] Selection/Deselection/Removed Animations
- [x] Multiple Selection
- [x] Images
- [x] Multiline Label
- [x] [Documentation](https://efremidze.github.io/Magnetic)

## Requirements

- iOS 9.0+
- Xcode 9.0+
- Swift 5 (Magnetic 3.x), Swift 4 (Magnetic 2.x), Swift 3 (Magnetic 1.x)

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

A `Node` object is a SKShapeNode subclass.

#### Interaction

```swift
// add circular node
let node = Node(text: "Italy", image: UIImage(named: "italy"), color: .red, radius: 30)
magnetic.addChild(node)

// add custom node
let node = Node(text: "France", image: UIImage(named: "france"), color: .blue, path: path, marginScale: 1.1)
magnetic.addChild(node)

// remove node
node.removeFromParent()
```

#### Properties

```swift
var text: String? // node text
var image: UIImage? // node image
var color: UIColor // node color
```

#### Animations

```swift
override func selectedAnimation() {
    // override selected animation
}

override func deselectedAnimation() {
    // override deselected animation
}

override func removedAnimation(completion: @escaping () -> Void) {
    // override removed animation
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
            texture = image.map { SKTexture(image: $0) }
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

## Mentions

- [Natasha The Robot's Newsleter 126](https://swiftnews.curated.co/issues/126#start)

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Credits

https://github.com/igalata/Bubble-Picker

## License

Magnetic is available under the MIT license. See the LICENSE file for more info.
