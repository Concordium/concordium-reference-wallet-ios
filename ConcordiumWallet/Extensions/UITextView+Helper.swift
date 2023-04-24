//
//  UITextView+Helper.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 2.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
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
}
