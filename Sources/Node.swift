//
//  Node.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/25/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

@objcMembers open class Node: SKShapeNode {
    
    public lazy var label: SKMultilineLabelNode = { [unowned self] in
        let label = SKMultilineLabelNode()
        label.fontName = "Avenir-Black"
        label.fontSize = 12
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.width = self.frame.width
        label.separator = " "
        addChild(label)
        return label
    }()
    
    /**
     The text displayed by the node.
     */
    open var text: String? {
        get { return label.text }
        set { label.text = newValue }
    }
    
    /**
     The image displayed by the node.
     */
    open var image: UIImage? {
        didSet {
//            let url = URL(string: "https://picsum.photos/1200/600")!
//            let image = UIImage(data: try! Data(contentsOf: url))
            texture = image.map { SKTexture(image: $0.aspectFill(self.frame.size)) }
        }
    }
    
    /**
     The color of the node.
     
     Also blends the color with the image.
     */
    open var color: UIColor = .clear {
        didSet {
            self.fillColor = color
        }
    }
    
    open var texture: SKTexture?
    
    /**
     The selection state of the node.
     */
    open var isSelected: Bool = false {
        didSet {
            guard isSelected != oldValue else { return }
            if isSelected {
                selectedAnimation()
            } else {
                deselectedAnimation()
            }
        }
    }
    
    /**
     Creates a node with a custom path.
     
     - Parameters:
        - text: The text of the node.
        - image: The image of the node.
        - color: The color of the node.
        - path: The path of the node.
        - marginScale: The margin scale of the node.
     
     - Returns: A new node.
     */
    public init(text: String?, image: UIImage?, color: UIColor, path: CGPath, marginScale: CGFloat = 1.01) {
        super.init()
        self.path = path
        self.physicsBody = {
            var transform = CGAffineTransform.identity.scaledBy(x: marginScale, y: marginScale)
            let body = SKPhysicsBody(polygonFrom: path.copy(using: &transform)!)
            body.allowsRotation = false
            body.friction = 0
            body.linearDamping = 3
            return body
        }()
        self.color = color
        self.strokeColor = .white
        _ = self.text
        configure(text: text, image: image, color: color)
    }
    
    /**
     Creates a node with a circular path.
     
     - Parameters:
        - text: The text of the node.
        - image: The image of the node.
        - color: The color of the node.
        - radius: The radius of the node.
        - marginScale: The margin scale of the node.
     
     - Returns: A new node.
     */
    public convenience init(text: String?, image: UIImage?, color: UIColor, radius: CGFloat, marginScale: CGFloat = 1.01) {
        let path = SKShapeNode(circleOfRadius: radius).path!
        self.init(text: text, image: image, color: color, path: path, marginScale: marginScale)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configure(text: String?, image: UIImage?, color: UIColor) {
        self.text = text
        self.image = image
        self.color = color
    }
    
    override open func removeFromParent() {
        removedAnimation() {
            super.removeFromParent()
        }
    }
    
    /**
     The animation to execute when the node is selected.
     */
    open func selectedAnimation() {
        run(.scale(to: 4/3, duration: 0.2))
        if let texture = texture {
            self.fillTexture = texture
        }
    }
    
    /**
     The animation to execute when the node is deselected.
     */
    open func deselectedAnimation() {
        run(.scale(to: 1, duration: 0.2))
        self.fillTexture = nil
        self.fillColor = color
    }
    
    /**
     The animation to execute when the node is removed.
     
     - important: You must call the completion block.
     
     - parameter completion: The block to execute when the animation is complete. You must call this handler and should do so as soon as possible.
     */
    open func removedAnimation(completion: @escaping () -> Void) {
        run(.fadeOut(withDuration: 0.2), completion: completion)
    }
    
}
