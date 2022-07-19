//
//  GameViewController.swift
//  Boids iOS
//
//  Created by Chris Mills on 7/16/22.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    let config = GameConfig()
    @IBOutlet weak var cohesion_slider: UISlider!
    @IBOutlet weak var separation_slider: UISlider!
    @IBOutlet weak var alignment_slider: UISlider!
    @IBOutlet weak var seek_slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cohesion_slider.value = Float(config.cohesion_intensity)
        separation_slider.value = Float(config.separation_intensity)
        alignment_slider.value = Float(config.alignment_intensity)
        seek_slider.value = Float(config.seek_intensity)
        
        let scene = GameScene.newGameScene(config: config)

        let skView = self.view as! SKView
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func onCohesionSliderDidChange(_ sender: UISlider) {
        config.cohesion_intensity = CGFloat(sender.value)
    }
    
    @IBAction func onSeparationSliderDidChange(_ sender: UISlider) {
        config.separation_intensity = CGFloat(sender.value)
    }
    
    @IBAction func onAlignmentSliderDidChange(_ sender: UISlider) {
        config.alignment_intensity = CGFloat(sender.value)
    }
    
    @IBAction func onSeekSliderDidChange(_ sender: UISlider) {
        config.seek_intensity = CGFloat(sender.value)
    }
}
