//
//  UIBarButtonItem+Helper.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 2.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    // MARK: - Public
    
    class func leftBarButtonItemWithImage(_ image: UIImage, controller: UIViewController) -> UIBarButtonItem
    {
        let edgeInsets = UIEdgeInsets(top: 11.0, left: 0.0, bottom: 11.0, right: 11.0 * 2.0)
        
        return UIBarButtonItem.barButtonItemWithImage(image, edgeInsets: edgeInsets, selector: Selector(("onLeftBarButton")), controller: controller)
    }
    
    class func rightBarButtonItemWithImage(_ image: UIImage, controller: UIViewController) -> UIBarButtonItem
    {
        let edgeInsets = UIEdgeInsets(top: 11.0, left: 11.0 * 2.0, bottom: 11.0, right: 0.0)
        
        return UIBarButtonItem.barButtonItemWithImage(image, edgeInsets: edgeInsets, selector: Selector(("onRightBarButton")), controller: controller)
    }
    
    class func leftBarButtonItemWithBigImage(_ image: UIImage, controller: UIViewController) -> UIBarButtonItem
    {
        let edgeInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: 6.0, right: 6.0 * 2.0)
        
        return UIBarButtonItem.barButtonItemWithImage(image, edgeInsets: edgeInsets, selector: Selector(("onLeftBarButton")), controller: controller)
    }
    
    class func rightBarButtonItemWithBigImage(_ image: UIImage, controller: UIViewController) -> UIBarButtonItem
    {
        let edgeInsets = UIEdgeInsets(top: 6.0, left: 6.0 * 2.0, bottom: 6.0, right: 0.0)
        
        return UIBarButtonItem.barButtonItemWithImage(image, edgeInsets: edgeInsets, selector: Selector(("onRightBarButton")), controller: controller)
    }
    
    // MARK: - Private
    
    private class func barButtonItemWithImage(_ image: UIImage, edgeInsets: UIEdgeInsets, selector: Selector, controller: UIViewController) -> UIBarButtonItem
    {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = edgeInsets
        button.showsTouchWhenHighlighted = true
        button.imageView?.contentMode = .scaleAspectFit
        if controller.responds(to: selector) {
            button.addTarget(controller, action: selector, for: .touchUpInside)
        }
        
        let barButtonItem = UIBarButtonItem(customView: button)
        
        // Apply this only on versions iOS 11 and above
        if #available(iOS 11.0, *) {
            barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        }
        
        return barButtonItem
    }
}
