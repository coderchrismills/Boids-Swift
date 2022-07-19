//
//  Boid.swift
//  Boids
//
//  Created by Chris Mills on 7/17/22.
//

import SpriteKit

class Boid: SKSpriteNode {
    let max_flock_speed: CGFloat = 2
    let max_goal_speed: CGFloat = 1
    let max_applied_force: CGFloat = 0.1
    
    let character_size: CGFloat = 36

    var velocity: CGPoint = CGPoint.zero
    var acceleration: CGPoint = CGPoint.zero
    
    fileprivate var is_debug_enable: Bool = false
    
    fileprivate let percepction_radius: CGFloat = 100
    fileprivate let perception_field_of_view_in_radians:CGFloat = .pi / 2
    
    fileprivate var neighbors: [Boid] = []
    
    fileprivate var cohesion_intensity: CGFloat = 0.0
    fileprivate var separation_intensity: CGFloat = 0.0
    fileprivate var alignment_intensity: CGFloat = 0.0
    fileprivate var seek_intensity: CGFloat = 0.0
    
    fileprivate var is_seeking: Bool = false
    fileprivate var seek_goal: CGPoint = CGPoint.zero
    fileprivate var prior_to_seek_velocity: CGPoint = CGPoint.zero
    fileprivate var seek_cooldown_in_frames: CGFloat = 10
    
    fileprivate var cohesion_observation: NSKeyValueObservation?
    fileprivate var separation_observation: NSKeyValueObservation?
    fileprivate var alignment_observation: NSKeyValueObservation?
    fileprivate var seek_observation: NSKeyValueObservation?
    
    public init(with charater: Character, config:GameConfig) {
        super.init(texture: nil, color: SKColor.clear, size: CGSize())
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        position = CGPoint.zero
        
        size = CGSize(width: character_size, height: character_size)
        
        cohesion_intensity = config.cohesion_intensity
        cohesion_observation = config.observe(\GameConfig.cohesion_intensity, options: .new) { config, change in
            self.cohesion_intensity = change.newValue ?? 0.0
        }
        
        separation_intensity = config.separation_intensity
        separation_observation = config.observe(\GameConfig.separation_intensity, options: .new) { config, change in
            self.separation_intensity = change.newValue ?? 0.0
        }
        
        alignment_intensity = config.alignment_intensity
        alignment_observation = config.observe(\GameConfig.alignment_intensity, options: .new) { config, change in
            self.alignment_intensity = change.newValue ?? 0.0
        }
        
        seek_intensity = config.seek_intensity
        seek_observation = config.observe(\GameConfig.seek_intensity, options: .new) { config, change in
            self.seek_intensity = change.newValue ?? 0.0
        }
        
        let label = SKLabelNode(text: String(charater))
        label.fontSize = character_size
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: label.frame.midX, y: label.frame.midY)
        
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func set_debug_enabled(enable: Bool) {
#if os(iOS) || os(tvOS)
        if is_debug_enable != enable {
            is_debug_enable = enable
            let debugNode = self.childNode(withName: "DebugNode") ?? SKNode()
            if enable {
                debugNode.name = "DebugNode"
                let circle = SKShapeNode(circleOfRadius: percepction_radius)
                circle.strokeColor = .black
                circle.glowWidth = 1.0
                debugNode.addChild(circle)
                addChild(debugNode)
                // doing some rotation here b/c our fish emoji points to the left rather than "up"
                let arc_path = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: percepction_radius, startAngle: 0, endAngle: perception_field_of_view_in_radians, clockwise: true)
                arc_path.flatness = 100
                let arc = SKShapeNode()
                arc.lineWidth = 20
                arc.strokeColor = .green
                arc.path = arc_path.cgPath
                arc.zRotation = .pi - (perception_field_of_view_in_radians / 2)
                debugNode.addChild(arc)
                
                let line = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 2, height: 100))
                line.lineWidth = 10
                line.strokeColor = .black
                line.zRotation = .pi / 2
                debugNode.addChild(line)
            } else {
                debugNode.removeAllChildren()
                debugNode.removeFromParent()
            }
        }
#endif
    }
    
    public func update(dt: TimeInterval) {
        if neighbors.count > 0 {
            update_seek()
            update_cohesion()
            update_separation()
            update_alignment()
        }
        
        update_bounds()
        update_position(dt: CGFloat(dt))
        update_orientation(dt: CGFloat(dt))
    }
    
    public func update_list_of_neighbors(flock: [Boid]) {
        if is_debug_enable {
            for n in neighbors {
                n.color = .clear
            }
        }
        
        let neighbors = flock.filter {
            if ($0 == self) { return false }
            let distance = $0.position.distance(from: self.position)
            
            let delta = ($0.position - position).unit
            let n_dot_v = delta * self.velocity.unit
            let half_angle = perception_field_of_view_in_radians / 2
            let theta = acos(n_dot_v)
            return (distance < percepction_radius) && (theta < half_angle)
        }
        
        if is_debug_enable {
            for n in neighbors {
                n.color = .red
            }
        }
        
        self.neighbors = neighbors
    }
    
    public func update_cohesion() {
        assert(neighbors.count > 0)
        
        var center_of_mass = CGPoint.zero
        for boid in neighbors {
            center_of_mass += boid.position
        }

        center_of_mass = center_of_mass / CGFloat(neighbors.count)
        var target_velocity = center_of_mass - self.position
        target_velocity = target_velocity.limit(to: max_flock_speed)
        var force = target_velocity - velocity
        force = force.limit(to: max_applied_force)
        force = force * cohesion_intensity
        acceleration += force
    }
    
    public func update_separation() {
        assert(neighbors.count > 0)
        
        var target_velocity = CGPoint.zero
        for boid in neighbors {
            let delta = (self.position - boid.position).unit
            target_velocity += delta
        }
        
        target_velocity = (target_velocity / CGFloat(neighbors.count))
        target_velocity = target_velocity.limit(to: max_flock_speed)
        var force = (target_velocity - velocity)
        force = force.limit(to: max_applied_force)
        force = force * separation_intensity
        acceleration += force
    }
    
    public func update_alignment() {
        assert(neighbors.count > 0)
        
        var target_velocity = CGPoint.zero
        for boid in neighbors {
            target_velocity += boid.velocity
        }
        
        target_velocity = (target_velocity / CGFloat(neighbors.count))
        target_velocity = target_velocity.limit(to: max_flock_speed)
        var force = (target_velocity - velocity)
        force = force.limit(to: max_applied_force)
        force = force * alignment_intensity
        acceleration += force
    }
    
    public func update_bounds() {
        guard let parent_frame = parent?.frame else {
            return
        }
        
        let half_width = parent_frame.size.width / 2
        let half_height = parent_frame.size.height / 2
        let horizontal_range = (-half_width)...(half_width)
        let vertial_range = (-half_height)...(half_height)
        
        if position.x < horizontal_range.lowerBound {
            position.x = horizontal_range.upperBound - (self.frame.size.width / 2)
        }

        if position.x > horizontal_range.upperBound {
            position.x = horizontal_range.lowerBound + (self.frame.size.width / 2)
        }

        if position.y < vertial_range.lowerBound {
            position.y = vertial_range.upperBound - (self.frame.size.height / 2)
        }

        if position.y > vertial_range.upperBound {
            position.y = vertial_range.lowerBound + (self.frame.size.height / 2)
        }
    }
    
    fileprivate func update_seek() {
        if is_seeking {
            if position.is_within(of: seek_goal, tolerance: character_size) || seek_cooldown_in_frames < 0 {
                is_seeking = false
                seek_goal = CGPoint.zero
                velocity = prior_to_seek_velocity
            } else {
                var force = (seek_goal - position)
                force = force.limit(to: max_goal_speed)
                force = force * seek_intensity
                acceleration += force
            }
            seek_cooldown_in_frames = seek_cooldown_in_frames - 1
        }
    }
    
    public func seek(to point: CGPoint) {
        is_seeking = true
        seek_goal = point
        prior_to_seek_velocity = velocity
        seek_cooldown_in_frames = 10
    }
    
    fileprivate func update_position(dt: CGFloat) {
        velocity += acceleration
        velocity = velocity.limit(to: max_flock_speed)
        position += velocity
    }
    
    fileprivate func update_orientation(dt: CGFloat) {
        if velocity.length_squared > CGFloat.leastNormalMagnitude {
            let theta = velocity.phase
            zRotation = (.pi + theta)
        } else {
            zRotation = CGFloat.zero
        }
    }
}
