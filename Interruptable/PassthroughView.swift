//
//  PassthroughView.swift
//  Interruptable
//
//  Created by Janum Trivedi on 7/21/20.
//  Copyright © 2020 Janum Trivedi. All rights reserved.
//

import Foundation
import UIKit

protocol PassthroughViewDelegate: class {
    func receivedPassthroughTouch()
}

class PassthroughView: UIView {
    
    weak var delegate: PassthroughViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTestedView = super.hitTest(point, with: event)
        if hitTestedView == self {
            delegate?.receivedPassthroughTouch()
            return nil
        } else {
            return hitTestedView
        }
    }
}

