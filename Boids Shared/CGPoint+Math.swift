//
//  CGPoint+Math.swift
//  Boids
//
//  Created by Chris Mills on 7/16/22.
//

import CoreGraphics

extension CGPoint {
    public func is_within(of point: CGPoint, tolerance: CGFloat) -> Bool {
        return self.distance(from: point) <= tolerance
    }
    
    public func is_outside(of point: CGPoint, tolerance: CGFloat) -> Bool {
        return is_within(of: point, tolerance: tolerance) == false
    }
    
    public func get_point_by_rotating_around(_ origin: CGPoint, degrees_in_radians: CGFloat) -> CGPoint {
        let delta = self - origin
        let radius = delta.length
        let orientation = self.phase
        let new_orientation = orientation + degrees_in_radians
        let new_x = origin.x + radius * cos(new_orientation)
        let new_y = origin.y + radius * sin(new_orientation)
        return CGPoint(x: new_x, y: new_y)
    }
    
    public var length_squared: CGFloat {
        return x*x + y*y
    }
    
    public var length: CGFloat {
        return sqrt(length_squared)
    }
    
    public var unit: CGPoint {
        return self * (1.0 / length)
    }
    
    public var phase: CGFloat {
        return atan2(y, x)
    }
    
    public func limit(to max_magnitude: CGFloat) -> CGPoint {
        var limited = self
        if (self.length > max_magnitude) {
            limited = self.unit * max_magnitude
        }
        return limited
    }
    
    static public func get_random_point(bounds: CGSize) -> CGPoint {
        let x = CGFloat.random(in: (-bounds.width/2)...(bounds.width/2))
        let y = CGFloat.random(in: (-bounds.height/2)...(bounds.height/2))
        return CGPoint(x: x, y: y)
    }
    
    public func distance(from point: CGPoint) -> CGFloat {
        return (self - point).length
    }
    
    public func distance_squared(from point: CGPoint) -> CGFloat {
        return (self - point).length_squared
    }
    
    static public prefix func + (value: CGPoint) -> CGPoint {
        return value
    }

    static public prefix func - (value: CGPoint) -> CGPoint {
        return CGPoint(x: -value.x, y: -value.y)
    }

    static public func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static public func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static public func * (left: CGPoint, right: CGPoint) -> CGFloat {
        return left.x * right.x + left.y * right.y
    }

    static public func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }

    static public func * (left: CGFloat, right: CGPoint) -> CGPoint {
        return CGPoint(x: right.x * left, y: right.y * left)
    }

    static public func / (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x / right, y: left.y / right)
    }

    static public func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }

    static public func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }

    static public func *= (left: inout CGPoint, right: CGFloat) {
        left = left * right
    }

    static public func /= (left: inout CGPoint, right: CGFloat) {
        left = left / right
    }
    
}
