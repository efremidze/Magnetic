//
//  MagneticView.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/28/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

public class MagneticView: SKView {
    
    @objc
    public lazy var magnetic: Magnetic = { [unowned self] in
        let scene = Magnetic(size: self.bounds.size)
        self.presentScene(scene)
        return scene
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        _ = magnetic
        accessibilityCreateSelectionRotor(withName: "Selected",
                                          usingScene: magnetic)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        magnetic.size = bounds.size
    }
    
}

// Accessibility extension
private extension MagneticView {
    private func accessibilityCreateSelectionRotor(withName name: String,
                                                   usingScene magnet: Magnetic) {

		// iOS 10+ allows a VoiceOver user to skip to selected elements
		guard #available(iOS 10.0, *) else { return }

        let selectedRotor = UIAccessibilityCustomRotor(name: name) { predicate in
            // Sort by Node name/text and ensure there is at least 1 selected Node
            let selected = magnet
                .selectedChildren
                .sorted { $0.text ?? ""  < $1.text ?? "" }
            let all = magnet.children.compactMap { $0 as? Node }
            guard selected.count > 0 else { return nil }
            
            // See which direction the user is scrolling
            let isDirectionForward = predicate.searchDirection == .next
            
            // Get the index of current focused Node
            var currentNodeIndex = isDirectionForward ? all.count : -1
            if
                let current = predicate.currentItem.targetElement,
                let currentNode = current as? Node {
                currentNodeIndex = all.firstIndex(of: currentNode) ?? currentNodeIndex
            }
            
            if let node = self.fetchNextSelectedNode(inDirection: isDirectionForward,
                                                     fromCurrentNodeIndex: currentNodeIndex,
                                                     inNodeArray: all) {
                return UIAccessibilityCustomRotorItemResult(targetElement: node,
                                                            targetRange: nil)
            } else { return nil }
        }

        accessibilityCustomRotors = [selectedRotor]
    }

    private func fetchNextSelectedNode(inDirection forwards: Bool,
                                       fromCurrentNodeIndex index: Int,
                                       inNodeArray all: [Node]) -> Node? {
        // A closure used to update the while loop
        let nextSearchNode = { (nodeIndex) in forwards ? nodeIndex - 1 : nodeIndex + 1 }
        
        var searchNode = nextSearchNode(index)
        while searchNode >= 0 && searchNode < all.count {
            defer { searchNode = nextSearchNode(searchNode) }
            if all[searchNode].isSelected {
                return all[searchNode]
            }
        }
        
        return nil
    }

}
