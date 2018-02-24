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
    public lazy var middleMagneticField: SKFieldNode = { [unowned self] in
        let field = SKFieldNode.radialGravityField()
        self.addChild(field)
        return field
    }()
    /**
     The left field node that accelerates the nodes.
     */
    public lazy var leftMagneticField: SKFieldNode = { [unowned self] in
        let field = SKFieldNode.radialGravityField()
        self.addChild(field)
        return field
        }()
    /**
     The right field node that accelerates the nodes.
     */
    public lazy var rightMagneticField: SKFieldNode = { [unowned self] in
        let field = SKFieldNode.radialGravityField()
        self.addChild(field)
        return field
        }()
    /**
     Allows for two magnetic fields along the x axis.  Off by default.
     **/
    open var allowDualMagneticFields: Bool = false
    
    /**
     Controls whether you can select multiple nodes. On by default.
     */
    open var allowsMultipleSelection: Bool = true

    /**
     Lets the user move individule nodes.  Off by default.
     **/
    open var allowSingleNodeMovement: Bool = false
    
    /**
     How fast the node follows the user's finger.  Default is 30.
     **/
    open var singleNodeMovementAcceleration: CGFloat = 30
    
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
        configureFields()
        
    }
    func configureFields(){
        updateField(field: middleMagneticField, position: CGPoint(x: size.width / 2, y: size.height / 2))
        if allowDualMagneticFields{
            updateField(field: leftMagneticField, position: CGPoint(x: size.width/2 - size.width/4, y: size.height / 2))
            updateField(field: rightMagneticField, position: CGPoint(x: size.width/2 + size.width/4, y: size.height / 2))
            middleMagneticField.strength = -middleMagneticField.strength
        }
    }
    func updateField(field:SKFieldNode, position:CGPoint){
        let strength = Float(max(size.width, size.height))
        let radius = strength.squareRoot() * 100
        
        field.region = SKRegion(radius: radius)
        field.minimumRadius = radius
        field.strength = strength
        field.position = position
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

var movingNode: Node? = nil
var initialTouchLocation: CGPoint? = nil
var initialTouchStartedOnNode: Bool = false
var movingNodeTimer: Timer? = nil

extension Magnetic {
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            if initialTouchLocation == nil{
                initialTouchLocation = point
                
                if allowSingleNodeMovement{
                    movingNode = node(at: point)
                }
                initialTouchStartedOnNode = movingNode != nil
            }
            if allowSingleNodeMovement && initialTouchStartedOnNode, let node = movingNode{
                moveNode(node, to: point)
                setReacurringMoveTimer(for: node, to: point)
            }
            else if allowAllNodeMovement{
                moveAllNodes(touchLocation: point, previousTouchLocation: touch.previousLocation(in: self))
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let point = touch.location(in: self)
            let initialLocation = initialTouchLocation ?? point
            let shouldAllowSelection = initialLocation.distance(from: point) < nodeSelectionForgivenessDistance
            
            if shouldAllowSelection,
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
            }
        }
        resetTouchMovedState()
    }
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetTouchMovedState()
    }
    
    /**
     Need to do this otherwise the node floats back to the center when the user is not moving their finger
     **/
    func setReacurringMoveTimer(for node:SKNode, to touchLocation:CGPoint){
        if movingNodeTimer != nil{
            movingNodeTimer?.invalidate()
        }
        movingNodeTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self,
                                               selector: #selector(self.keepNodeStill(for:)),
                                               userInfo: ["touchLocation":touchLocation, "node": node],
                                               repeats: true)
    }
    
    func moveAllNodes(touchLocation: CGPoint, previousTouchLocation: CGPoint){
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
    
    func node(at point: CGPoint)-> Node?{
        return nodes(at: point).flatMap({ $0 as? Node }).filter({ $0.path!.contains(convert(point, to: $0)) }).first
    }
    
    func moveNode(_ node:SKNode, to touchLocation:CGPoint){
        let convertedTapLocation = convert(touchLocation, to: node)
        let direction = CGVector(dx: convertedTapLocation.x * singleNodeMovementAcceleration, dy: convertedTapLocation.y * singleNodeMovementAcceleration)
        node.physicsBody?.applyForce(direction)
    }
    
    @objc func keepNodeStill(for timer: Timer){
        let params = timer.userInfo as! [String:Any?]
        moveNode(params["node"] as! SKNode, to: params["touchLocation"] as! CGPoint)
    }
    
    func resetTouchMovedState(){
        movingNode = nil
        movingNodeTimer?.invalidate()
        movingNodeTimer = nil
        initialTouchLocation = nil
        initialTouchStartedOnNode = false
    }
}
