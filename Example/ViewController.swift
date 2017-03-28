//
//  ViewController.swift
//  Example
//
//  Created by Lasha Efremidze on 3/8/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit
import Magnetic

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
            let name = UIImage.all.randomItem()
            let node = Node(title: name.capitalized, image: UIImage(named: name), color: UIColor.all.randomItem(), radius: 40)
            scene.addChild(node)
        }
    }
    
}
