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
        self.addChild(field)
        return field
    }()
    
    /**
     Controls whether you can select multiple nodes. On by default.
     */
    open var allowsMultipleSelection: Bool = true

    /**
     Lets the user move individule nodes.  Off by default.
     **/
    open var allowSingleNodeMovement: Bool = false
    
    /**
     Lets the user move all of the nodes at once.  On by default.
     **/
    open var allowAllNodeMovement: Bool = true
    
    /**
     The amount of distance the user's finger is able to travle before considering it a move event instead of a selection.  Default is 5px.
     **/
    open var nodeSelectionForgivenessDistance: CGFloat = 5
    
    /**
     The selected children.
     */
    open var selectedChildren: [Node] {
        return children.flatMap { $0 as? Node }.filter { $0.isSelected }
    }
    
    /**
     The object that acts as the delegate of the scene.
     
     The delegate must adopt the MagneticDelegate protocol. The delegate is not retained.
     */
    open weak var magneticDelegate: MagneticDelegate?
    
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

var isDragging: Bool = false
var movingNode: SKNode? = nil
var initialTouchLocation: CGPoint? = nil
var initialTouchStartedOnNode: Bool = false
var movingNodeTimer: Timer? = nil

extension Magnetic {
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if movingNode == nil &&
                allowSingleNodeMovement &&
                initialTouchLocation == nil{
                for node in children {
                    let nodeTouchPoint=node.convert(touchLocation, to: node)
                    if node.frame.contains(nodeTouchPoint)
                    {
                        movingNode = node
                        if initialTouchLocation == nil{
                            initialTouchStartedOnNode = true
                        }
                        break
                    }
                }
            }
            if !isDragging{
                isDragging = true
                initialTouchLocation = touchLocation
            }
            if allowSingleNodeMovement && initialTouchStartedOnNode, let node = movingNode{
                let convertedTapLocation = convert(touchLocation, to: node)
                let direction = CGVector(dx: convertedTapLocation.x * 30, dy: convertedTapLocation.y * 30)
                node.physicsBody?.applyForce(direction)
                
                if movingNodeTimer != nil{
                    movingNodeTimer?.invalidate()
                    movingNodeTimer = nil
                }
                movingNodeTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.moveNode(timer:)), userInfo: ["touchLocation":touchLocation, "node": node], repeats: true)
            } else if allowAllNodeMovement{
                let previous = touch.previousLocation(in: self)
                if touchLocation.distance(from: previous) == 0 { return }
                
                let x = touchLocation.x - previous.x
                let y = touchLocation.y - previous.y
                
                for node in children {
                    let distance = node.position.distance(from: touchLocation)
                    let acceleration: CGFloat = 3 * pow(distance, 1/2)
                    let direction = CGVector(dx: x * acceleration, dy: y * acceleration)
                    node.physicsBody?.applyForce(direction)
                }
            }
        }
    }
    @objc func moveNode(timer: Timer){
        let params = timer.userInfo as! [String:Any?]
        let node = params["node"] as! SKNode
        let touchLocation = params["touchLocation"] as! CGPoint
        
        let convertedTapLocation = convert(touchLocation, to: node)
        let direction = CGVector(dx: convertedTapLocation.x * 30, dy: convertedTapLocation.y * 30)
        node.physicsBody?.applyForce(direction)
    }
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        movingNode = nil
        movingNodeTimer?.invalidate()
        movingNodeTimer = nil
        if let touch = touches.first{
            let point = touch.location(in: self)
            let initialLocation = initialTouchLocation ?? point
            
            let shouldAllowSelection = (!isDragging || (initialLocation.distance(from: point) < nodeSelectionForgivenessDistance))
            
            if shouldAllowSelection,
                let node = nodes(at: point).flatMap({ $0 as? Node }).filter({ $0.path!.contains(convert(point, to: $0)) }).first
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
            }
        }
        isDragging = false
        initialTouchLocation = nil
        initialTouchStartedOnNode = false
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }
    
}
