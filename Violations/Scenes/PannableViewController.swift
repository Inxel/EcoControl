////
////  PannableViewController.swift
////  Violations
////
////  Created by Артем Загоскин on 14/04/2019.
////  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
////
//
//import UIKit
//
//class ViewControllerPannable: UIViewController {
//    private var panGestureRecognizer: UIPanGestureRecognizer?
//    private var originalPosition: CGPoint?
//    private var currentPositionTouched: CGPoint?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
//        view.addGestureRecognizer(panGestureRecognizer!)
//    }
//    
//    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
//        let translation = panGesture.translation(in: view)
//
//        if panGesture.state == .began {
//            originalPosition = view.center
//            currentPositionTouched = panGesture.location(in: view)
//        } else if panGesture.state == .changed {
//            view.frame.origin = CGPoint(
//                x: self.view.frame.origin.x,
//                y: translation.y < self.view.frame.origin.y ? self.view.frame.origin.y : translation.y
//            )
//        } else if panGesture.state == .ended {
//            let velocity = panGesture.velocity(in: view)
//
//            if velocity.y >= 1000 {
//                UIView.animate(withDuration: 0.2
//                    , animations: {
//                        self.view.frame.origin = CGPoint(
//                            x: self.view.frame.origin.x,
//                            y: self.view.frame.size.height
//                        )                }, completion: { (isCompleted) in
//                    if isCompleted {
//                        self.dismiss(animated: false, completion: nil)
//                    }
//                })
//            } else {
//                UIView.animate(withDuration: 0.15, animations: {
//                    self.view.center = self.originalPosition!
//                })
//            }
//        }
//    }
//}
