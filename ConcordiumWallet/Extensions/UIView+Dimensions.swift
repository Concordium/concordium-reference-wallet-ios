//
//  UIView+Dimensions.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 3.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    //
    var originX: CGFloat {
        get {
            return self.frame.origin.x
        }
        
        set(originX) {
            self.frame.origin.x = originX
        }
    }
    
    //
    var originY: CGFloat {
        get {
            return self.frame.origin.y
        }
        
        set(originY) {
            self.frame.origin.y = originY
        }
    }
    
    //
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set(width) {
            self.frame.size.width = width
        }
    }
    
    //
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set(height) {
            self.frame.size.height = height
        }
    }
    
    // MARK: - Animated
    func setOriginX(_ originX: CGFloat, withAnimationDuration animationDuration: TimeInterval) {
        UIView.animate(withDuration: animationDuration) {
            self.originX = originX
        }
    }
    
    func setOriginY(_ originY: CGFloat, withAnimationDuration animationDuration: TimeInterval) {
        UIView.animate(withDuration: animationDuration) {
            self.originY = originY
        }
    }
    
    func setWidth(_ width: CGFloat, withAnimationDuration animationDuration: TimeInterval) {
        UIView.animate(withDuration: animationDuration) {
            self.width = width
        }
    }
    
    func setHeight(_ height: CGFloat, withAnimationDuration animationDuration: TimeInterval) {
        UIView.animate(withDuration: animationDuration) {
            self.height = height
        }
    }
}
