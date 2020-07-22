//
//  Utilities.swift
//  Interruptable
//
//  Created by Janum Trivedi on 7/20/20.
//  Copyright © 2020 Janum Trivedi. All rights reserved.
//

import Foundation
import UIKit

func mapRange(value: CGFloat, inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat) -> CGFloat {
    return ((value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin);
}

func clip(value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
    return min(upper, max(value, lower))
}

func rubberband(value: CGFloat, range: ClosedRange<CGFloat>, interval: CGFloat) -> CGFloat {
    // * x = distance from the edge
    // * c = constant value, UIScrollView uses 0.55
    // * d = dimension, either width or height
    // b = (1.0 – (1.0 / ((x * c / d) + 1.0))) * d
    
    if range.contains(value) {
        return value
    }
    
    let c: CGFloat = 0.55

    let d: CGFloat = interval

    if value > range.upperBound {
        let x = value - range.upperBound
        
        let b = (1.0 - (1.0 / ((x * c / d) + 1.0))) * d
        
        return range.upperBound + b
    } else {
        let x = range.lowerBound - value
        
        let b = (1.0 - (1.0 / ((x * c / d) + 1.0))) * d
        
        return range.lowerBound - b
        
    }
}

func project(point: CGPoint, velocity: CGPoint, decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue) -> CGPoint {
    return CGPoint(
        x: point.x + project(initialVelocity: velocity.x, decelerationRate: decelerationRate),
        y: point.y + project(initialVelocity: velocity.y, decelerationRate: decelerationRate)
    )
}

func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
    return (initialVelocity / 1000) * decelerationRate / (1 - decelerationRate)
}

extension UIViewController {
    func add(child viewController: UIViewController) {
        self.view.addSubview(viewController.view)
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }
}
