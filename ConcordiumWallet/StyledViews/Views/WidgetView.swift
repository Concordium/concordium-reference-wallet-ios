//
//  WidgetView.swift
//  ConcordiumWallet
//
//  Created by Concordium on 12/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//
import UIKit

@IBDesignable
class WidgetView: BaseView {

    override func initialize() {
        super.initialize()

        applyConcordiumEdgeStyle()
    }
}

extension UIView {
    func applyConcordiumEdgeStyle() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 1
        layer.shadowRadius = 10.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.cornerRadius = 10.0
    }
    
    func applyConcordiumEdgeStyle (corners: UIRectCorner, radius: CGFloat = 4.0) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        
//        layer.shadowPath = path.cgPath
//        layer.masksToBounds = false
//
//        layer.shadowColor = UIColor.red.cgColor
//        layer.shadowOffset = .zero
//        layer.shadowOpacity = 1.0
//        layer.shadowRadius = 10.0
//        layer.shouldRasterize = true
//        layer.rasterizationScale = UIScreen.main.scale
    }
//
//    func applyShadow(color: UIColor, alpha: Float, x: CGFloat, y: CGFloat, blur: CGFloat, spread: CGFloat) {
//        layer.shadowColor = color.cgColor
//        layer.shadowOpacity = alpha
//        layer.shadowOffset = CGSize(width: x, height: y)
//        layer.shadowRadius = blur / 2.0
//        if spread == 0 {
//            layer.shadowPath = nil
//        } else {
//            let rect = bounds.insetBy(dx: -spread, dy: -spread)
//            layer.shadowPath = UIBezierPath(rect: rect).cgPath
//        }
//    }
    
}
