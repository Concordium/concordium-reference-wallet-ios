//
// Created by Concordium on 15/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func setYPosition(_ yPos: CGFloat) {
        self.frame.origin.y = yPos
    }
    
    func setBottom(_ bottomPos: CGFloat) {
        self.frame.origin.y = bottomPos - self.frame.size.height
    }
    
    func setXPosition(_ xPos: CGFloat) {
        self.frame.origin.x = xPos
    }
    
    func translateYPosition(_ dist: CGFloat) {
        self.frame.origin.y += dist
    }
    
    func translateXPosition(_ dist: CGFloat) {
        self.frame.origin.x += dist
    }
}

extension UIView {
    func shake() {
        transform = CGAffineTransform(translationX: 5, y: 0)
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 1,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.transform = CGAffineTransform.identity
            }
        )
    }
    var isHiddenInStackView: Bool {
            get {
                return isHidden
            }
            set {
                if isHidden != newValue {
                    isHidden = newValue
                }
            }
        }
}
