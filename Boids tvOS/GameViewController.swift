//
//  GameViewController.swift
//  Boids tvOS
//
//  Created by Chris Mills on 7/16/22.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
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
