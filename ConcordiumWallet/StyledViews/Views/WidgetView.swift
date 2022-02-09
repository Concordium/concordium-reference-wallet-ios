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
    func applyConcordiumEdgeStyle(color: UIColor = UIColor.primary) {
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.cornerRadius = 10.0
    }
    
    func applyConcordiumEdgeStyle (corners: UIRectCorner, radius: CGFloat = 10.0) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        layer.borderWidth = 1
        layer.borderColor = UIColor.primary.cgColor
    }

}
