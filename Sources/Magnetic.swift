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
        field.strength = 6000
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
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let previous = touch.previousLocation(in: self)
            
            var x = location.x - previous.x
            var y = location.y - previous.y
            let b = sqrt(pow(location.x, 2) + pow(location.y, 2))
            x = b == 0 ? 0 : (x / b)
            y = b == 0 ? 0 : (y / b)
            
            if x == 0 && y == 0 {
                return
            }
            
            moving = true
            
            let pushStrength: CGFloat = 10000
            var direction = CGVector(dx: pushStrength * x, dy: pushStrength * y)

            magneticField.position = location
            
//            if let node = atPoint(location) as? Node {
//                let pushStrength: CGFloat = 10000
//                let direction = CGVector(dx: pushStrength * x, dy: pushStrength * y)
//                node.physicsBody?.applyImpulse(direction)
//            }
            
            for node in children {
//                let w = node.frame.width / 2
//                let h = node.frame.height / 2
                
                let distance = node.position.distance(from: magneticField.position)
                let acceleration = pushStrength / pow(distance, 2)
                direction.dx *= acceleration
                direction.dy *= acceleration
                
//                let distance = node.position.distance(from: location)
//                let mod = CGFloat(magneticField.strength) / pow(distance, 1.7)
//                print(distance)
//                print(mod)
//                
//                if mod < 1 {
//                    direction.dx *= mod
//                    direction.dy *= mod
//                }
//                
//                if !(-w...(size.width + w) ~= node.position.x) && (node.position.x * x) > 0 {
//                    direction.dx = 0
//                }
//                
//                if !(-h...(size.height + h) ~= node.position.y) && (node.position.y * y) > 0 {
//                    direction.dy = 0
//                }
                
//                let dx = (node.frame.midX / frame.maxX) * 0.5
//                let dy = (node.frame.midY / frame.maxY) * 0.5
//                if direction.dx < 0 {
//                    direction.dx *= dx
//                } else {
//                    direction.dx *= 1 - dx
//                }
//                if direction.dy < 0 {
//                    direction.dy *= dy
//                } else {
//                    direction.dy *= 1 - dy
//                }
                
                node.physicsBody?.applyImpulse(direction)
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
