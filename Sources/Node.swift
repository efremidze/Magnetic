//
//  Node.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/25/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

open class Node: SKShapeNode {
    
    lazy var mask: SKCropNode = { [unowned self] in
        let node = SKCropNode()
        node.maskNode = {
            let node = SKShapeNode(circleOfRadius: self.frame.width / 2)
            node.fillColor = .white
            node.strokeColor = .clear
            return node
        }()
        self.addChild(node)
        _ = self.maskOverlay // Masking creates aliasing. This masks the aliasing.
        return node
    }()
    
    lazy var maskOverlay: SKShapeNode = { [unowned self] in
        let node = SKShapeNode(circleOfRadius: self.frame.width / 2)
        node.fillColor = .clear
        node.strokeColor = self.strokeColor
        self.addChild(node)
        return node
    }()
    
    public lazy var label: SKLabelNode = { [unowned self] in
        let label = SKLabelNode(fontNamed: "Avenir-Black")
        label.fontSize = 12
        label.verticalAlignmentMode = .center
        self.mask.addChild(label)
        return label
    }()
    
    public lazy var sprite: SKSpriteNode = { [unowned self] in
        let sprite = SKSpriteNode()
        sprite.size = self.frame.size
        sprite.colorBlendFactor = 0.5
        self.mask.addChild(sprite)
        return sprite
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
            guard let image = image else { return }
            texture = SKTexture(image: image)
        }
    }
    
    /**
     The color of the node.
     
     Also blends the color with the image.
     */
    open var color: UIColor {
        get { return sprite.color }
        set { sprite.color = newValue }
    }
    
    private(set) var texture: SKTexture!
    
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
     Creates a circular node object.
     
     - Parameters:
        - text: The text of the node.
        - image: The image of the node.
        - color: The color of the node.
        - radius: The radius of the circle.
     
     - Returns: A new node.
     */
    public convenience init(text: String?, image: UIImage?, color: UIColor, radius: CGFloat) {
        self.init()
        self.init(circleOfRadius: radius)
        
        self.physicsBody = {
            let body = SKPhysicsBody(circleOfRadius: radius + 2)
            body.allowsRotation = false
            body.friction = 0
            body.linearDamping = 3
            return body
        }()
        self.fillColor = .white
        self.strokeColor = .white
        _ = self.sprite
        _ = self.text
        configure(text: text, image: image, color: color)
    }
    
    open func configure(text: String?, image: UIImage?, color: UIColor) {
        self.text = text
        self.image = image
        self.color = color
    }
    
    override open func removeFromParent() {
        removeAnimation() {
            super.removeFromParent()
        }
    }
    
    /**
     The animation to execute when the node is selected.
     */
    open func selectedAnimation() {
        run(.scale(to: 4/3, duration: 0.2))
        sprite.run(SKAction.setTexture(texture))
    }
    
    /**
     The animation to execute when the node is deselected.
     */
    open func deselectedAnimation() {
        run(.scale(to: 1, duration: 0.2))
        sprite.texture = nil
    }
    
    /**
     The animation to execute when the node is removed.
     
     - important: You must call the completion block.
     
     - parameter completion: The block to execute when the animation is complete. You must call this handler and should do so as soon as possible.
     */
    open func removeAnimation(completion: @escaping () -> Void) {
        run(.fadeOut(withDuration: 0.2), completion: completion)
    }
    
}
