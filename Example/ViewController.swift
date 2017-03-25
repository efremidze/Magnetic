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
            let node = Node.make(radius: 30, color: UIColor(red: 255 / 255, green: 59 / 255, blue: 48 / 255, alpha: 1), text: "Hello")
            scene.addChild(node)
        }
    }
    
}

import SpriteKit

class Magnetic: SKScene {
    
    let bottomOffset: CGFloat = 200
    
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
            var bodyFrame = self.frame
            bodyFrame.size.width = CGFloat(magneticField.minimumRadius)
            bodyFrame.origin.x -= bodyFrame.size.width / 2
            bodyFrame.size.height = self.frame.size.height - bottomOffset
            bodyFrame.origin.y = self.frame.size.height - bodyFrame.size.height
            return bodyFrame
        }())
        magneticField.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2 + bottomOffset / 2)
    }
    
//    override init(size: CGSize) {
//        super.init(size: size)
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func addChild(_ node: SKNode) {
        var x = CGFloat.random(min: -bottomOffset, max: -node.frame.width)
        let y = CGFloat.random(
            min: frame.height - bottomOffset - node.frame.height,
            max: frame.height - node.frame.height
        )
        if children.count % 2 == 0 || children.isEmpty {
            x = CGFloat.random(
                min: frame.width + node.frame.width,
                max: frame.width + bottomOffset
            )
        }
        node.position = CGPoint(x: x, y: y)
        
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.friction = 0
        node.physicsBody?.linearDamping = 3
        
        super.addChild(node)
    }
    
    var touchPoint: CGPoint?
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchPoint = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !moving, let point = touchPoint, let node = atPoint(point) as? Node {
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
    
    lazy var label: SKLabelNode = { [unowned self] in
        let label = SKLabelNode(fontNamed: "Avenir-Heavy")
        label.fontSize = 14
        label.verticalAlignmentMode = .center
        self.addChild(label)
        return label
    }()
    
    lazy var sprite: SKSpriteNode = { [unowned self] in
        let node = SKCropNode()
        node.maskNode = {
            let node = SKShapeNode(circleOfRadius: self.frame.width)
            node.fillColor = .white
            node.strokeColor = .clear
            return node
        }()
        let sprite = SKSpriteNode(color: .red, size: self.frame.size)
        sprite.color = .red
        sprite.colorBlendFactor = 0.5
        node.addChild(sprite)
        self.addChild(node)
        return sprite
    }()
    
    class func make(radius: CGFloat, color: UIColor, text: String) -> Node {
//    class func make(radius: CGFloat, color: UIColor, text: String, image: UIImage) -> Node {
        let node = Node(circleOfRadius: radius)
        node.physicsBody = SKPhysicsBody(circleOfRadius: radius + 1)
        node.fillColor = color
        node.strokeColor = .clear
        _ = node.sprite
        node.label.text = text
        return node
    }
    
    func selectedChanged(_ selected: Bool) {
        var actions = [SKAction]()
        if selected {
            sprite.texture = SKTexture(imageNamed: "argentina")
            actions += [SKAction.scale(to: 1.3, duration: 0.2)]
        } else {
            sprite.texture = nil
            actions += [SKAction.scale(to: 1, duration: 0.2)]
        }
        let group = SKAction.group(actions)
        run(group)
    }
    
}

extension CGPoint {
    
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - self.x, point.y - self.y)
    }
    
}

extension CGFloat {
    
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
    
}
