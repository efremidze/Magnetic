//
//  MagneticView+Accessibility.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 6/6/22.
//  Copyright © 2022 efremidze. All rights reserved.
//

import Foundation

extension MagneticView {
    func accessibilityCreateSelectionRotor(withName name: String, usingScene magnet: Magnetic) {
        let selectedRotor = UIAccessibilityCustomRotor(name: name) { predicate in
            // Sort by Node name/text and ensure there is at least 1 selected Node
            let selected = magnet.selectedChildren.sorted { $0.text ?? ""  < $1.text ?? "" }
            let all = magnet.children.compactMap { $0 as? Node }
            guard selected.count > 0 else { return nil }
            
            // See which direction the user is scrolling
            let isDirectionForward = predicate.searchDirection == .next
            
            // Get the index of current focused Node
            var currentNodeIndex = isDirectionForward ? all.count : -1
            if
                let current = predicate.currentItem.targetElement,
                let currentNode = current as? Node
            {
                currentNodeIndex = all.firstIndex(of: currentNode) ?? currentNodeIndex
            }
            
            if let node = self.fetchNextSelectedNode(inDirection: isDirectionForward, fromCurrentNodeIndex: currentNodeIndex, inNodeArray: all) {
                return UIAccessibilityCustomRotorItemResult(targetElement: node, targetRange: nil)
            } else { return nil }
        }
        
        accessibilityCustomRotors = [selectedRotor]
    }
    
    func fetchNextSelectedNode(inDirection forwards: Bool, fromCurrentNodeIndex index: Int, inNodeArray all: [Node]) -> Node? {
        // A closure used to update the while loop
        let nextSearchNode = { forwards ? $0 - 1 : $0 + 1 }
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
