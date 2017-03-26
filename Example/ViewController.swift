//
//  ViewController.swift
//  Example
//
//  Created by Lasha Efremidze on 3/8/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var skView: SKView {
        return view as! SKView
    }
    
    override func loadView() {
        super.loadView()
        
        self.view = SKView(frame: self.view.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = Magnetic(size: self.view.bounds.size)
        skView.presentScene(scene)
        
        for _ in 0..<20 {
            let image = UIImage.all.randomItem()
            let node = Node.make(radius: 30, color: UIColor.all.randomItem(), text: image, image: image)
            scene.addChild(node)
        }
    }
    
}

import SpriteKit

class Magnetic: SKScene {
    
    lazy var magneticField: SKFieldNode = { [unowned self] in
        let field = SKFieldNode.radialGravityField()
        field.region = SKRegion(radius: 10000)
        field.minimumRadius = 10000
        field.strength = 8000
        self.addChild(field)
        return field
    }()
    
    override func didMove(to view: SKView) {
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
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func addChild(_ node: SKNode) {
        var x = CGFloat.random(0, -node.frame.width) // left
        if children.count % 2 == 0 {
            x = CGFloat.random(frame.width, frame.width + node.frame.width) // right
        }
        let y = CGFloat.random(node.frame.height, frame.height - node.frame.height)
        node.position = CGPoint(x: x, y: y)
        super.addChild(node)
    }
    
    var moving: Bool = false
    
    override func atPoint(_ p: CGPoint) -> SKNode {
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
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
            
            for node in children {
                let pushStrength: CGFloat = 10000
                
                let w = node.frame.width / 2
                let h = node.frame.height / 2
                
                var direction = CGVector(dx: pushStrength * x, dy: pushStrength * y)
                
                if !(-w...(size.width + w) ~= node.position.x) && (node.position.x * x) > 0 {
                    direction.dx = 0
                }
                
                if !(-h...(size.height + h) ~= node.position.y) && (node.position.y * y) > 0 {
                    direction.dy = 0
                }
                
                node.physicsBody?.applyForce(direction)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !moving, let point = touches.first?.location(in: self), let node = atPoint(point) as? Node {
            node.selected = !node.selected
        }
        moving = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        moving = false
    }
    
}

class Node: SKShapeNode {
    
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
    
    class func make(radius: CGFloat, color: UIColor, text: String, image: String) -> Node {
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
