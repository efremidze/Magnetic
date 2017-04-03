//
//  Magnetic.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/8/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

public protocol MagneticDelegate: class {
    func magnetic(_ magnetic: Magnetic, didSelect node: Node)
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node)
}

open class Magnetic: SKScene {
    
    /**
     The field node that accelerates the nodes.
     */
    public lazy var magneticField: SKFieldNode = { [unowned self] in
        let field = SKFieldNode.radialGravityField()
        field.region = SKRegion(radius: 2000)
        field.minimumRadius = 2000
        field.strength = 500
        self.addChild(field)
        return field
    }()
    
    /**
     Controls whether you can select multiple nodes.
     */
    open var allowsMultipleSelection: Bool = true
    
    var moving: Bool = false
    
    /**
     The selected children.
     */
    open var selectedChildren: [Node] {
        return children.flatMap { $0 as? Node }.filter { $0.selected }
    }
    
    /**
     The object that acts as the delegate of the scene.
     
     The delegate must adopt the MagneticDelegate protocol. The delegate is not retained.
     */
    open weak var magneticDelegate: MagneticDelegate?
    
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
    
    override open func addChild(_ node: SKNode) {
        var x = -node.frame.width // left
        if children.count % 2 == 0 {
            x = frame.width + node.frame.width // right
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
            
            if location.distance(from: previous) == 0 { return }
            
            moving = true
            
            let x = location.x - previous.x
            let y = location.y - previous.y
            
            for node in children {
                let distance = node.position.distance(from: location)
                let acceleration: CGFloat = 3 * pow(distance, 1/2)
                let direction = CGVector(dx: x * acceleration, dy: y * acceleration)
                node.physicsBody?.applyForce(direction)
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !moving, let point = touches.first?.location(in: self), let node = atPoint(point) as? Node {
            if node.selected {
                node.selected = false
                magneticDelegate?.magnetic(self, didDeselect: node)
            } else {
                if !allowsMultipleSelection, let selectedNode = selectedChildren.first {
                    selectedNode.selected = false
                    magneticDelegate?.magnetic(self, didDeselect: selectedNode)
                }
                node.selected = true
                magneticDelegate?.magnetic(self, didSelect: node)
            }
        }
        moving = false
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        moving = false
    }
    
}
