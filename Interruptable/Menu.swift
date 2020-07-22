//
//  Menu.swift
//  Interruptable
//
//  Created by Janum Trivedi on 7/20/20.
//  Copyright © 2020 Janum Trivedi. All rights reserved.
//

import Foundation
import UIKit

/*

 GOALS:
 
 - Present a menu
 - As the menu presents, tapping outside should cancel and dismiss the menu
 - Dimiss the menu via pan
 - Pan should rubberband
 - Dismissing via pan should project velocity
 - As the pan moves, the alpha/progress should update
 
 */

class ExtendedView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.inset(by: UIEdgeInsets(top: 0, left: -18, bottom: 0, right: 0))
        return expandedBounds.contains(point)
    }
}

class MenuViewController: TableViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        self.view = ExtendedView(frame: self.view.frame)
        super.viewDidLoad()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public protocol MenuContainerDelegate: class {
    func didChangeToProgress(progress: CGFloat)
}

class MenuContainerView: UIViewController, PassthroughViewDelegate {
    
    let backdropView = PassthroughView()
    let menuViewController = MenuViewController()
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    private var progress: CGFloat = 0
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        setupViews()
        setupGestures()
        setProgress(0, animated: false)
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool = true) {
        // Update the model progress
        self.progress = progress
        
        // Update the UI
        updateViews(with: self.progress, animated: animated)
    }
    
    func setupViews() {
        self.view = PassthroughView(frame: view.frame)

        view.addSubview(backdropView)
        backdropView.delegate = self
        
        backdropView.frame = self.view.frame
        backdropView.backgroundColor = .black
        
        self.add(child: menuViewController)
    }
    
    func setupGestures() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        menuViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    
    // MARK: - PassthroughViewDelegate
    
    func receivedPassthroughTouch() {
        if isPresented() {
            dismiss()
        }
    }
    
    
    // MARK: - Gestures
    
    private var initialGestureAnimationProgress: CGFloat = 0
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: menuViewController.view)
        let velocity = sender.velocity(in: menuViewController.view)
        
        let projectedTranslation = project(point: translation, velocity: velocity)
        
        if sender.state == UIGestureRecognizer.State.began {
            initialGestureAnimationProgress = self.progress
        }
        else if sender.state == UIGestureRecognizer.State.changed {
            
            let unbandedProgress = -translation.x / menuWidth + initialGestureAnimationProgress
            
            let bandedProgress = rubberband(value: unbandedProgress, range: 0...1, interval: 0.70)
            
            setProgress(bandedProgress, animated: false)
            
        } else if sender.state == UIGestureRecognizer.State.ended {
            let unbandedProgress = -projectedTranslation.x / menuWidth + initialGestureAnimationProgress
            
            let shouldPresent = (unbandedProgress >= 0.5)
            setProgress(shouldPresent ? 1 : 0, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateViews(with progress: CGFloat, animated: Bool) {
        let updates = {
            self.backdropView.alpha = self.backdropAlpha(for: progress)
            self.menuViewController.view.alpha     = self.menuAlpha(for: progress)
            self.menuViewController.view.frame     = self.menuFrame(for: progress)
        }
        
        if animated {
            animate(block: updates)
        } else {
            updates()
        }
    }
    
    func menuAlpha(for progress: CGFloat) -> CGFloat {
        return clip(value: mapRange(value: progress, inMin: 0, inMax: 1, outMin: 0.4, outMax: 0.8), lower: 0, upper: 1)
    }
    
    func backdropAlpha(for progress: CGFloat) -> CGFloat {
        return clip(value: mapRange(value: progress, inMin: 0, inMax: 1, outMin: 0, outMax: 0.2), lower: 0, upper: 0.6)
    }
    
    var menuWidth: CGFloat {
        return self.view.frame.size.width * 0.60
    }

    func menuFrame(for progress: CGFloat) -> CGRect {
        let originX = mapRange(value: progress, inMin: 0, inMax: 1, outMin: view.frame.size.width, outMax: view.frame.size.width - menuWidth)
        return CGRect(
            x: originX,
            y: 0,
            width: menuWidth,
            height: view.frame.size.height
        )
    }
    
    func isPresented() -> Bool {
        return progress > 0
    }
    
    func isFullyPresented() -> Bool {
        return progress >= 1
    }
    
    func toggle() {
        isPresented() ? dismiss() : present()
    }
    
    func present() {
        setProgress(1, animated: true)
    }
    
    func dismiss() {
        setProgress(0, animated: true)
    }
    
    func animate(block: @escaping () -> ()) {
        let options = UIView.AnimationOptions(arrayLiteral: .allowUserInteraction, .curveEaseIn, .beginFromCurrentState)
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.80, initialSpringVelocity: 0, options: options, animations: {
            block()
        }) { (finished) in

        }
    }
}
