//
//  GameScene.swift
//  Boids Shared
//
//  Created by Chris Mills on 7/16/22.
//

/// Emoji's for sprites, some structure, and extensions for CGPoint from [christopherkriens](https://github.com/christopherkriens/boids)
/// Initial "inpriration" from work slack post to [Flocking Algorithm in Unity, Part 1: Introduction](https://www.youtube.com/watch?v=mjKINQigAE4)

import SpriteKit

// TODO: Make UI driven
struct GameConfig {
#if os(iOS) || os(tvOS)
    let number_of_boids: Int = 100
#elseif os(OSX)
    let number_of_boids: Int = 100
#elseif os(watchOS)
    let number_of_boids: Int = 10
#else
    let number_of_boids: Int = 0
#endif
    
    let max_flock_speed: CGFloat = 2
    let max_goal_speed: CGFloat = 1
    let max_applied_force: CGFloat = 0.1
    let cohesion_intensity: CGFloat = 0.1
    let separation_intensity: CGFloat = 0.2
    let alignment_intensity: CGFloat = 0.3
    let seek_intensity: CGFloat = 0.3
}

class GameScene: SKScene {
    fileprivate let config = GameConfig()
    fileprivate var flock = [Boid]()
    fileprivate var current_frame_count:Int = 0
    fileprivate var update_frequency:Int = 30
    fileprivate var last_time_updated: TimeInterval = 0
    
    class func newGameScene() -> GameScene {
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        for i in 0..<config.number_of_boids {
            let boid = Boid(with: "🐠", config: config)
            let start_position = CGPoint.get_random_point(bounds: size)
            boid.position = start_position
            boid.velocity = CGPoint.get_random_point(bounds: size).unit
            boid.name = "timmy-\(i)"
            flock.append(boid)
            addChild(boid)
        }
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
        let need_to_update_neighbors = current_frame_count % update_frequency == 0
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

