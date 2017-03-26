//
//  Node.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/25/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

open class Node: SKShapeNode {
    
    var selected: Bool = false {
        didSet {
            guard selected != oldValue else { return }
            selectedChanged(selected)
        }
    }
    
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
    
    lazy var label: SKLabelNode = { [unowned self] in
        let label = SKLabelNode(fontNamed: "Avenir-Heavy")
        label.fontSize = 10
        label.verticalAlignmentMode = .center
        self.mask.addChild(label)
        return label
        }()
    
    lazy var sprite: SKSpriteNode = { [unowned self] in
        let sprite = SKSpriteNode(color: self.color, size: self.frame.size)
        sprite.colorBlendFactor = 0.5
        self.mask.addChild(sprite)
        return sprite
        }()
    
    var image: String!
    var color: UIColor!
    
    open class func make(radius: CGFloat, color: UIColor, text: String, image: String) -> Node {
        let node = Node(circleOfRadius: radius)
        node.physicsBody = {
            let body = SKPhysicsBody(circleOfRadius: radius + 1)
            body.isDynamic = true
            body.affectedByGravity = false
            body.allowsRotation = false
            body.mass = 0.3
            body.friction = 0
            body.linearDamping = 3
            return body
        }()
        node.fillColor = .black
        node.strokeColor = .clear
        node.image = image
        node.color = color
        _ = node.sprite
        node.label.text = text
        return node
    }
    
    func selectedChanged(_ selected: Bool) {
        var actions = [SKAction]()
        if selected {
            sprite.texture = SKTexture(imageNamed: image)
            actions.append(SKAction.scale(to: 1.3, duration: 0.2))
        } else {
            sprite.texture = nil
            actions.append(SKAction.scale(to: 1, duration: 0.2))
        }
        run(SKAction.group(actions))
    }
    
}
