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
#if TARGET_INTERFACE_BUILDER
        let edgeColor =  UIColor(red: 64/255, green: 134/255, blue: 171/255, alpha: 1)// An IB-only stand-in color.
#else
        let edgeColor = UIColor.primary // The run-time color we really want.
#endif
        applyConcordiumEdgeStyle(color: edgeColor)
    }
}

extension UIView {
    func applyConcordiumEdgeStyle(color: UIColor = UIColor.primary) {
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.cornerRadius = 10.0
    }
    
    func applyConcordiumEdgeStyle(corners: UIRectCorner, radius: CGFloat = 10.0, color: UIColor = UIColor.primary) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
    }

}
