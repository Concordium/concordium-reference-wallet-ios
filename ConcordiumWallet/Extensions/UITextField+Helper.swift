//
//  UITextField+Helper.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 3.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    typealias ToolbarItem = (title: String, target: Any, selector: Selector)
    
    func addToolbar(leading: [ToolbarItem] = [], trailing: [ToolbarItem] = []) {
        let toolbar = UIToolbar()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let leadingItems = leading.map { item in
            return UIBarButtonItem(title: item.title, style: .plain, target: item.target, action: item.selector)
        }
        
        let trailingItems = trailing.map { item in
            return UIBarButtonItem(title: item.title, style: .plain, target: item.target, action: item.selector)
        }
        
        var toolbarItems: [UIBarButtonItem] = leadingItems
        toolbarItems.append(flexibleSpace)
        toolbarItems.append(contentsOf: trailingItems)
        
        toolbar.setItems(toolbarItems, animated: false)
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    //
    func setLeftIcon(_ icon: UIImage?, withSize size: CGSize, padding: CGFloat, andViewMode mode: UITextField.ViewMode) {
        let outerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size.width + padding, height: size.height))
        let iconImageView  = UIImageView(frame: CGRect(x: padding, y: 0.0, width: size.width, height: size.height))
        iconImageView.image = icon
        outerView.addSubview(iconImageView)
        
        leftView = outerView
        leftViewMode = mode
    }
    
    func setRightIcon(_ icon: UIImage?, withSize size: CGSize, padding: CGFloat, andViewMode mode: UITextField.ViewMode) {
        let outerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size.width + padding, height: size.height))
        let iconImageView  = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        iconImageView.image = icon
        outerView.addSubview(iconImageView)
        
        rightView = outerView
        rightViewMode = mode
    }
}
