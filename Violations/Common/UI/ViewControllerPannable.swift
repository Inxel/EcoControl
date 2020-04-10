//
//  ViewControllerPannable.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


class ViewControllerPannable: UIViewController {
    
    // MARK: - Properties
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        var tapRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
        return tapRecognizer
    }()
    
    private var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0) 
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
}


// MARK: - Actions

extension ViewControllerPannable {
    
    @IBAction private func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        
        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            if touchPoint.y - initialTouchPoint.y > 0 {
                view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: view.frame.size.width, height: view.frame.size.height)
            }
        case .ended, .cancelled:
            if touchPoint.y - initialTouchPoint.y > 75 {
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                }
            }
        default:
            break
        }
    }
    
}
