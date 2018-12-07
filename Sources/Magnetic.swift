//
//  Magnetic.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/8/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

@objc public protocol MagneticDelegate: class {
    func magnetic(_ magnetic: Magnetic, didSelect node: Node)
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node)
}

@objcMembers open class Magnetic: SKScene {
    
    /**
     The field node that accelerates the nodes.
     */
    open lazy var magneticField: SKFieldNode = { [unowned self] in
        let field = SKFieldNode.radialGravityField()
        self.addChild(field)
        return field
    }()
    
    /**
     Controls whether you can select multiple nodes.
     */
    open var allowsMultipleSelection: Bool = true
    
    public enum NodeMovementType {
        case multiple
        case single
    }
    
    open var nodeMovementType: NodeMovementType = .multiple
    
    /**
     How fast the node follows the user's finger. Default is 30.
     **/
    open var singleNodeMovementAcceleration: CGFloat = 30
    
    /**
     The amount of distance the user's finger is able to trave; before considering it a move event instead of a selection. Default is 5px.
     **/
    open var nodeSelectionForgivenessDistance: CGFloat = 5
    
    /**
     The selected children.
     */
    open var selectedChildren: [Node] {
        return children.compactMap { $0 as? Node }.filter { $0.isSelected }
    }
    
    /**
     The object that acts as the delegate of the scene.
     
     The delegate must adopt the MagneticDelegate protocol. The delegate is not retained.
     */
    open weak var magneticDelegate: MagneticDelegate?
    
    var movingNode: Node?
    var initialTouchLocation: CGPoint?
    var timer: Timer?
    
    override open var size: CGSize {
        didSet {
            configure()
        }
    }
    
    override public init(size: CGSize) {
        super.init(size: size)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .white
        scaleMode = .aspectFill
        configure()
    }
    
    func configure() {
        let strength = Float(max(size.width, size.height))
        let radius = strength.squareRoot() * 100
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsBody = SKPhysicsBody(edgeLoopFrom: { () -> CGRect in
            var frame = self.frame
            frame.size.width = CGFloat(radius)
            frame.origin.x -= frame.size.width / 2
            return frame
        }())
        
        magneticField.region = SKRegion(radius: radius)
        magneticField.minimumRadius = radius
        magneticField.strength = strength
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
    
}

extension Magnetic {
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        if initialTouchLocation == nil{
            initialTouchLocation = point
            
            if case .single = nodeMovementType {
                movingNode = node(at: point)
            }
        }
        switch nodeMovementType {
        case .multiple:
            moveAllNodes(touchLocation: point, previousTouchLocation: touch.previousLocation(in: self))
        case .single:
            guard let node = movingNode else { return }
            moveNode(node, to: point)
            setReacurringMoveTimer(for: node, to: point)
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        let initialLocation = initialTouchLocation ?? point
        let shouldAllowSelection = initialLocation.distance(from: point) < nodeSelectionForgivenessDistance
        
        if
            shouldAllowSelection,
            let node = node(at: point)
        {
            if node.isSelected {
                node.isSelected = false
                magneticDelegate?.magnetic(self, didDeselect: node)
            } else {
                if !allowsMultipleSelection, let selectedNode = selectedChildren.first {
                    selectedNode.isSelected = false
                    magneticDelegate?.magnetic(self, didDeselect: selectedNode)
                }
                node.isSelected = true
                magneticDelegate?.magnetic(self, didSelect: node)
            }
            node.isSelected = true
            magneticDelegate?.magnetic(self, didSelect: node)
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        movingNode = nil
        timer?.invalidate()
        timer = nil
        initialTouchLocation = nil
    }
    
}

extension Magnetic {
    
    func setReacurringMoveTimer(for node: SKNode, to touchLocation: CGPoint) {
        timer?.invalidate()
        timer = Timer.schedule(every: 0.01) { [unowned self] timer in
            self.moveNode(node, to: touchLocation)
        }
    }
    
    func moveAllNodes(touchLocation: CGPoint, previousTouchLocation: CGPoint) {
        if touchLocation.distance(from: previousTouchLocation) == 0 { return }
        
        let x = touchLocation.x - previousTouchLocation.x
        let y = touchLocation.y - previousTouchLocation.y
        
        for node in children {
            let distance = node.position.distance(from: touchLocation)
            let acceleration: CGFloat = 3 * pow(distance, 1/2)
            let direction = CGVector(dx: x * acceleration, dy: y * acceleration)
            node.physicsBody?.applyForce(direction)
        }
    }
    
    func moveNode(_ node:SKNode, to touchLocation: CGPoint) {
        let convertedTapLocation = convert(touchLocation, to: node)
        let direction = CGVector(dx: convertedTapLocation.x * singleNodeMovementAcceleration, dy: convertedTapLocation.y * singleNodeMovementAcceleration)
        node.physicsBody?.applyForce(direction)
    }
    
//    func moveNode(_ node: SKNode, to touchLocation: CGPoint) {
//        let distance = node.position.distance(from: location)
//        let acceleration: CGFloat = 3 * pow(distance, 1/2)
//        let direction = CGVector(dx: x * acceleration, dy: y * acceleration)
//        node.physicsBody?.applyForce(direction)
//    }
    
    open func moveNodes(location: CGPoint, previous: CGPoint) {
        let x = location.x - previous.x
        let y = location.y - previous.y
        
        for node in children {
            let distance = node.position.distance(from: location)
            let acceleration: CGFloat = 3 * pow(distance, 1/2)
            let direction = CGVector(dx: x * acceleration, dy: y * acceleration)
            node.physicsBody?.applyForce(direction)
        }
    }
    
    open func node(at point: CGPoint) -> Node? {
        return nodes(at: point).compactMap { $0 as? Node }.filter { $0.path!.contains(convert(point, to: $0)) }.first
    }
    
}
