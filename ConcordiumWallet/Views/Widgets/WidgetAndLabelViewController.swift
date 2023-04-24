//
//  WidgetAndLabelViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 22/06/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class WidgetAndLabelViewController: BaseViewController, Storyboarded {

    @IBOutlet weak var topWidgetView: UIView!
    @IBOutlet weak var primaryBottomWidgetView: UIView!
    @IBOutlet weak var primaryLabel: UILabel!
    
    var topWidget: UIViewController?
    var primaryBottomWidget: UIViewController?
    var secondaryBottomWidget: UIViewController?
    var primaryCenterWidget: UIViewController?
    var primaryLabelString: String?
    var primaryLabelErrorString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topWidget = topWidget {
            add(child: topWidget, inside: topWidgetView)
        }
        
        if let primaryBottomWidget = primaryBottomWidget {
            add(child: primaryBottomWidget, inside: primaryBottomWidgetView)
        }
        
        if let primaryLabelErrorString = primaryLabelErrorString {
            primaryLabel.text = primaryLabelErrorString
            primaryLabel.textColor = .errorText
        } else {
            primaryLabel.text = primaryLabelString
        }
    }
}
