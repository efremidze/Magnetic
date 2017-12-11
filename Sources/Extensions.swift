//
//  Extensions.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/25/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

extension CGFloat {
    static func random(_ lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
}

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}

extension SKSpriteNode {
    func aspectFill(size: CGSize) {
        let _size = self.size
        let verticalRatio = _size.height / size.height
        let horizontalRatio = _size.width / size.width
        let scaleRatio = horizontalRatio > verticalRatio ? horizontalRatio : verticalRatio
        self.setScale(scaleRatio)
        self.size = size
    }
}
