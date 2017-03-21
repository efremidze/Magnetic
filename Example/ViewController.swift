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
        
        let scene = Magnetic(size: self.view.frame.size)
        skView.presentScene(scene)
        
        for _ in 0..<20 {
            let node = Node.make(radius: 30, color: .red, text: "Hello")
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
        field.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(field)
        return field
    }()
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = .white
//        self.scaleMode = .aspectFill
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        _ = magneticField
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addChild(_ node: SKNode) {
//        var x = CGFloat.random(min: -bottomOffset, max: -node.frame.size.width)
//        let y = CGFloat.random(
//            min: frame.size.height - bottomOffset - node.frame.size.height,
//            max: frame.size.height - topOffset - node.frame.size.height
//        )
//        
//        if floatingNodes.count % 2 == 0 || floatingNodes.isEmpty {
//            x = CGFloat.random(
//                min: frame.size.width + node.frame.size.width,
//                max: frame.size.width + bottomOffset
//            )
//        }
//        node.position = CGPoint(x: x, y: y)
        
        
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.mass = 0.3
        node.physicsBody?.friction = 0
        node.physicsBody?.linearDamping = 3
        super.addChild(node)
    }
    
    override func update(_ currentTime: TimeInterval) {
        children.forEach { node in
            let distanceFromCenter = self.magneticField.position.distance(from: node.position)
            node.physicsBody?.linearDamping = 2
            
            if distanceFromCenter <= 100 {
                node.physicsBody?.linearDamping += ((100 - distanceFromCenter) / 10)
            }
        }
    }
    
}

class Node: SKShapeNode {
    
    lazy var label: SKLabelNode = { [unowned self] in
        let label = SKLabelNode()
        label.fontSize = 14
        label.verticalAlignmentMode = .center
        self.addChild(label)
        return label
    }()
    
//    lazy var sprite: SKSpriteNode = { [unowned self] in
//        let sprite = SKSpriteNode()
//        self.addChild(sprite)
//        return sprite
//    }()
    
    class func make(radius: CGFloat, color: UIColor, text: String) -> Node {
//    class func make(radius: CGFloat, color: UIColor, text: String, image: UIImage) -> Node {
        let node = Node(circleOfRadius: radius)
        node.physicsBody = SKPhysicsBody(circleOfRadius: radius + 2)
        node.fillColor = color
        node.strokeColor = .clear
        node.label.text = text
        return node
    }

}

extension CGPoint {
    
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - self.x, point.y - self.y)
    }
    
}
