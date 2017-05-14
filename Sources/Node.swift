//
//  Node.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/25/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

open class Node: MaskNode {
    
    public lazy var label: SKMultilineLabelNode = { [unowned self] in
        let label = SKMultilineLabelNode()
        label.fontName = "Avenir-Black"
        label.fontSize = 12
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.width = self.frame.width
        label.separator = " "
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
            texture = image.map { SKTexture(image: $0) }
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
    
    override open var strokeColor: UIColor {
        didSet {
            maskOverlay.strokeColor = strokeColor
        }
    }
    
    private(set) var texture: SKTexture?
    
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
    public init(text: String?, image: UIImage?, color: UIColor, radius: CGFloat) {
        super.init(circleOfRadius: radius)
        
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
            sprite.run(.setTexture(texture))
        }
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
    open func removedAnimation(completion: @escaping () -> Void) {
        run(.fadeOut(withDuration: 0.2), completion: completion)
    }
    
}

open class MaskNode: SKShapeNode {
    
    let mask: SKCropNode
    let maskOverlay: SKShapeNode
    
    public init(circleOfRadius radius: CGFloat) {
        mask = SKCropNode()
        mask.maskNode = {
            let node = SKShapeNode(circleOfRadius: radius)
            node.fillColor = .white
            node.strokeColor = .clear
            return node
        }()
        
        maskOverlay = SKShapeNode(circleOfRadius: radius)
        maskOverlay.fillColor = .clear
        
        super.init()
        self.path = maskOverlay.path
        
        self.addChild(mask)
        self.addChild(maskOverlay)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
