//
//  Magnetic.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/8/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

open class Magnetic: SKScene {
    
    lazy var magneticField: SKFieldNode = { [unowned self] in
        let field = SKFieldNode.radialGravityField()
        field.region = SKRegion(radius: 10000)
        field.minimumRadius = 10000
        field.strength = 8000
        self.addChild(field)
        return field
    }()
    
    var moving: Bool = false
    
    override open func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.backgroundColor = .white
        self.scaleMode = .aspectFill
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: { () -> CGRect in
            var frame = self.frame
            frame.size.width = CGFloat(magneticField.minimumRadius)
            frame.origin.x -= frame.size.width / 2
            return frame
        }())
        magneticField.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
//    override init(size: CGSize) {
//        super.init(size: size)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override open func addChild(_ node: SKNode) {
        var x = CGFloat.random(0, -node.frame.width) // left
        if children.count % 2 == 0 {
            x = CGFloat.random(frame.width, frame.width + node.frame.width) // right
        }
        let y = CGFloat.random(node.frame.height, frame.height - node.frame.height)
        node.position = CGPoint(x: x, y: y)
        super.addChild(node)
    }
    
    override open func atPoint(_ p: CGPoint) -> SKNode {
        var node = super.atPoint(p)
        while true {
            if node is Node {
                return node
            } else if let parent = node.parent {
                node = parent
            } else {
                break
            }
        }
        return node
    }
    
}

extension Magnetic {
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let previous = touch.previousLocation(in: self)
            
            var x = location.x - previous.x
            var y = location.y - previous.y
            
//            magneticField.position.x += x
//            magneticField.position.y += y
            
            let b = location.length()
            x = b == 0 ? 0 : (x / b)
            y = b == 0 ? 0 : (y / b)
            
            if x == 0 && y == 0 {
                return
            }
            
            moving = true
            
            print(magneticField.position)
            
            for node in children {
//                let pushStrength: CGFloat = 10000
//                let distance = node.position.distance(from: magneticField.position)
//                let acceleration = pushStrength * max(0, min(0.01 / pow(distance, 2), 1))

                let acceleration: CGFloat = 5000
                var direction = CGVector(dx: x * acceleration, dy: y * acceleration)
                node.physicsBody?.applyForce(direction)
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !moving, let point = touches.first?.location(in: self), let node = atPoint(point) as? Node {
            node.selected = !node.selected
        }
        moving = false
        magneticField.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        moving = false
        magneticField.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
}
