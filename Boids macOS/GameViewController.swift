//
//  GameViewController.swift
//  Boids macOS
//
//  Created by Chris Mills on 7/16/22.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {
    let config = GameConfig()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene.newGameScene(config: config)
        
        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

}

