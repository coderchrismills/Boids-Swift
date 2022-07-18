//
//  Boid.swift
//  Boids
//
//  Created by Chris Mills on 7/17/22.
//

import SpriteKit

class Boid: SKSpriteNode {
    var max_flock_speed: CGFloat = 0
    var max_applied_force: CGFloat = 0
    var max_goal_speed: CGFloat = 0
    
    let character_size: CGFloat = 36

    var velocity: CGPoint = CGPoint.zero
    var acceleration: CGPoint = CGPoint.zero
    
    fileprivate let percepction_radius: CGFloat = 60
    fileprivate let perception_field_of_view_in_radians:CGFloat = .pi
    
    fileprivate var neighbors: [Boid] = []
    
    fileprivate var cohesion_intensity: CGFloat = 0.0
    fileprivate var separation_intensity: CGFloat = 0.0
    fileprivate var alignment_intensity: CGFloat = 0.0
    fileprivate var seek_intensity: CGFloat = 0.0
    
    fileprivate var is_seeking: Bool = false
    fileprivate var seek_goal: CGPoint = CGPoint.zero
    
    public init(with charater: Character, config:GameConfig) {
        super.init(texture: nil, color: SKColor.clear, size: CGSize())
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        position = CGPoint.zero
        
        size = CGSize(width: character_size, height: character_size)
        
        max_flock_speed = config.max_flock_speed
        max_goal_speed = config.max_goal_speed
        max_applied_force = config.max_applied_force
        
        cohesion_intensity = config.cohesion_intensity
        separation_intensity = config.separation_intensity
        alignment_intensity = config.alignment_intensity
        seek_intensity = config.seek_intensity
        
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
    
    public func set_cohesion_intensity(to intensity: CGFloat) {
        cohesion_intensity = intensity
    }
    
    public func set_separation_intensity(to intensity: CGFloat) {
        separation_intensity = intensity
    }
    
    public func set_alignment_intensity(to intensity: CGFloat) {
        alignment_intensity = intensity
    }
    
    public func update(dt: TimeInterval) {
        if neighbors.count > 0 {
            update_cohesion()
            update_alignment()
            update_seek()
            update_separation()
        }
        
        update_bounds()
        update_position(dt: CGFloat(dt))
        update_orientation(dt: CGFloat(dt))
    }
    
    public func update_list_of_neighbors(flock: [Boid]) {
        let neighbors = flock.filter {
            if ($0 == self) { return false }
            let distance = $0.position.distance(from: self.position)
            
            let n_dot_v = $0.velocity.unit * self.velocity.unit
            let theta = acos(n_dot_v)
            return (distance < percepction_radius) && (theta < perception_field_of_view_in_radians)
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
        target_velocity = target_velocity.unit * max_flock_speed
        var force = target_velocity - velocity
        force = force.unit * (max_applied_force * cohesion_intensity)
        acceleration += force
    }
    
    public func update_separation() {
        assert(neighbors.count > 0)
        
        var target_velocity = CGPoint.zero
        for boid in neighbors {
            let delta = (self.position - boid.position).unit
            target_velocity += delta
        }
        
        target_velocity = (target_velocity / CGFloat(neighbors.count)) * max_flock_speed
        var force = (target_velocity - velocity)
        force = force.unit * (max_applied_force * separation_intensity)
        acceleration += force
    }
    
    public func update_alignment() {
        assert(neighbors.count > 0)
        
        var target_velocity = CGPoint.zero
        for boid in neighbors {
            target_velocity += boid.velocity
        }
        
        target_velocity = (target_velocity / CGFloat(neighbors.count)) * max_flock_speed
        var force = (target_velocity - velocity)
        force = force.unit * (max_applied_force * alignment_intensity)
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
            if position.is_within(of: seek_goal, tolerance: character_size) {
                is_seeking = false
                seek_goal = CGPoint.zero
            } else {
                var force = (seek_goal - position).unit * max_goal_speed
                force = force.unit * (max_applied_force * seek_intensity)
                acceleration += force
            }
        }
    }
    
    public func seek(to point: CGPoint) {
        is_seeking = true
        seek_goal = point
    }
    
    fileprivate func update_position(dt: CGFloat) {
        velocity += acceleration
        if velocity.length > max_flock_speed {
            velocity = velocity.unit * max_flock_speed
        }
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
