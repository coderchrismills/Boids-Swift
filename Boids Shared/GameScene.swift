//
//  GameScene.swift
//  Boids Shared
//
//  Created by Chris Mills on 7/16/22.
//

/// Emoji's for sprites, some structure, and extensions for CGPoint from [christopherkriens](https://github.com/christopherkriens/boids)
/// Initial "inpriration" from work slack post to [Flocking Algorithm in Unity, Part 1: Introduction](https://www.youtube.com/watch?v=mjKINQigAE4)

import SpriteKit

@objc class GameConfig: NSObject {
    @objc dynamic var cohesion_intensity: CGFloat = 0.2
    @objc dynamic var separation_intensity: CGFloat = 0.15
    @objc dynamic var alignment_intensity: CGFloat = 0.3
    @objc dynamic var seek_intensity: CGFloat = 0.3
}

class GameScene: SKScene {
#if os(iOS) || os(tvOS)
    let number_of_boids: Int = 100
#elseif os(OSX)
    let number_of_boids: Int = 200
#elseif os(watchOS)
    let number_of_boids: Int = 10
#else
    let number_of_boids: Int = 0
#endif
    
    fileprivate var config = GameConfig()
    fileprivate var flock = [Boid]()
    fileprivate var current_frame_count:Int = 0
    fileprivate var update_frequency:Int = 30
    fileprivate var last_time_updated: TimeInterval = 0
    
    class func newGameScene(config: GameConfig) -> GameScene {
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        scene.scaleMode = .aspectFill
        
        scene.config = config
        
        return scene
    }
    
    func setUpScene() {
        for i in 0..<number_of_boids {
            let boid = Boid(with: "🐠", config: config)
            let start_position = CGPoint.get_random_point(bounds: size)
            boid.position = start_position
            boid.velocity = CGPoint.get_random_point(bounds: size).unit
            boid.name = "timmy-\(i)"
            flock.append(boid)
            addChild(boid)
        }
        
        flock[0].set_debug_enabled(enable: true)
    }
    
#if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
#else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
#endif

    override func update(_ currentTime: TimeInterval) {
        let dt = last_time_updated == 0 ? 0 : (currentTime - last_time_updated)
        let need_to_update_neighbors = true // current_frame_count % update_frequency == 0
        for boid in self.flock {
            if need_to_update_neighbors {
                boid.update_list_of_neighbors(flock: self.flock)
            }
            boid.update(dt: dt)
        }
    }
}

#if os(iOS) || os(tvOS)
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch_position = touches.first?.location(in: self) {
            for boid in flock {
                boid.seek(to: touch_position)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {
    override func mouseDown(with event: NSEvent) {
        
    }
    
    override func mouseDragged(with event: NSEvent) {
        
    }
    
    override func mouseUp(with event: NSEvent) {
        let click_position = event.location(in: self)
        for boid in flock {
            boid.seek(to: click_position)
        }
    }

}
#endif

