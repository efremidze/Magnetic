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
            node.fillColor = .black
            node.strokeColor = .clear
            return node
        }()
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
    
    open var title: String? {
        get { return label.text }
        set { label.text = newValue }
    }
    
    open var image: UIImage? {
        didSet {
            guard let image = image else { return }
            texture = SKTexture(image: image)
        }
    }
    
    open var color: UIColor {
        get { return sprite.color }
        set { sprite.color = newValue }
    }
    
    var texture: SKTexture!
    
    open var selected: Bool = false {
        didSet {
            guard selected != oldValue else { return }
            if selected {
                run(SKAction.scale(to: 4/3, duration: 0.2))
                sprite.run(SKAction.setTexture(texture))
            } else {
                run(SKAction.scale(to: 1, duration: 0.2))
                sprite.texture = nil
            }
        }
    }
    
    public convenience init(title: String?, image: UIImage?, color: UIColor, radius: CGFloat) {
        self.init()
        self.init(circleOfRadius: radius)
        
        self.physicsBody = {
            let body = SKPhysicsBody(circleOfRadius: radius + 2)
            body.allowsRotation = false
            body.friction = 0
            body.linearDamping = 2
            return body
        }()
        self.fillColor = .black
        self.strokeColor = .clear
        _ = self.sprite
        _ = self.title
        configure(title: title, image: image, color: color)
    }
    
    open func configure(title: String?, image: UIImage?, color: UIColor) {
        self.title = title
        self.image = image
        self.color = color
    }
    
}
