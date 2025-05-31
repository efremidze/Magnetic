# Magnetic

[![CI](https://github.com/efremidze/Magnetic/actions/workflows/ci.yml/badge.svg)](https://github.com/efremidze/Magnetic/actions/workflows/ci.yml)
[![CocoaPods](https://img.shields.io/cocoapods/v/Magnetic.svg)](https://cocoapods.org/pods/Magnetic)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![License](https://img.shields.io/github/license/efremidze/Magnetic.svg)](LICENSE)

**Magnetic** is a customizable bubble picker inspired by Apple Music’s genre selection.

<img src="/Images/demo2.gif" width="250" />

```sh
pod try Magnetic
```

---

## Features

- Add/remove nodes dynamically
- Smooth selection/deselection/removal animations
- Multiple selection support
- Node images and multiline labels
- [Documentation](https://efremidze.github.io/Magnetic)

---

## Requirements

| Version         | iOS        | Swift    |
|----------------|------------|----------|
| Magnetic 3.3.x | iOS 13.0+  | Swift 5  |
| Magnetic 3.2.1 | iOS 9.0+   | Swift 5  |
| Magnetic 2.x   | iOS 9.0+   | Swift 4  |
| Magnetic 1.x   | iOS 9.0+   | Swift 3  |

---

## Usage

`Magnetic` is an [`SKScene`](https://developer.apple.com/documentation/spritekit/skscene) subclass that is presented from an [`SKView`](https://developer.apple.com/documentation/spritekit/skview).

```swift
import Magnetic

class ViewController: UIViewController {

    var magnetic: Magnetic?

    override func loadView() {
        super.loadView()
        let magneticView = MagneticView(frame: view.bounds)
        magnetic = magneticView.magnetic
        view.addSubview(magneticView)
    }
}
```

### Properties

```swift
var magneticDelegate: MagneticDelegate? // Delegate
var allowsMultipleSelection: Bool // Defaults to true
var selectedChildren: [Node] // Currently selected nodes
```

---

## Nodes

A `Node` is a subclass of `SKShapeNode`.

### Interaction

```swift
let node = Node(text: "Italy", image: UIImage(named: "italy"), color: .red, radius: 30)
magnetic.addChild(node)

let customNode = Node(text: "France", image: UIImage(named: "france"), color: .blue, path: path, marginScale: 1.1)
magnetic.addChild(customNode)

node.removeFromParent()
```

### Node Properties

```swift
var text: String?
var image: UIImage?
var color: UIColor
```

### Animations

```swift
override func selectedAnimation() {
    // Customize selected animation
}

override func deselectedAnimation() {
    // Customize deselected animation
}

override func removedAnimation(completion: @escaping () -> Void) {
    // Customize removal animation
}
```

---

## Delegation

Use `MagneticDelegate` to observe selection state changes:

```swift
func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
    // Handle selection
}

func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
    // Handle deselection
}
```

---

## Customization

Subclass `Node` to define your own behavior or visuals:

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

---

## Installation

### CocoaPods

```ruby
use_frameworks!
pod "Magnetic"
```

### Carthage

```bash
github "efremidze/Magnetic"
```

---

## Mentions

- [Natasha The Robot's Newsletter #126](https://swiftnews.curated.co/issues/126#start)

---

## Contributing

- Found a bug? [Open an issue](https://github.com/efremidze/Magnetic/issues)
- Have a feature request? [Open an issue](https://github.com/efremidze/Magnetic/issues)
- Want to contribute? [Submit a pull request](https://github.com/efremidze/Magnetic/pulls)

---

## Acknowledgments

Inspired by [igalata/Bubble-Picker](https://github.com/igalata/Bubble-Picker)

---

## 📄 License

Magnetic is available under the MIT license. See the [LICENSE](LICENSE) file for details.
