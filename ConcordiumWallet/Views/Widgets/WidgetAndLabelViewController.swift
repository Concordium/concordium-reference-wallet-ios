//
//  WidgetAndLabelViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 22/06/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class WidgetAndLabelViewController: BaseViewController, SupportMail, Storyboarded {

    @IBOutlet weak var topWidgetView: UIView!
    @IBOutlet weak var primaryBottomWidgetView: UIView!
    @IBOutlet weak var secondaryBottomWidgetView: UIView!
    @IBOutlet weak var middleLabel: UILabel!
    
    var topWidget: UIViewController?
    var primaryBottomWidget: UIViewController?
    var secondaryBottomWidget: UIViewController?
    var middleLabelString: String?
    var middleLabelErrorString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topWidget = topWidget {
            add(child: topWidget, inside: topWidgetView)
        }
        
        if let primaryBottomWidget = primaryBottomWidget {
            add(child: primaryBottomWidget, inside: primaryBottomWidgetView)
        }
        
        if let secondaryBottomWidget = secondaryBottomWidget {
            add(child: secondaryBottomWidget, inside: secondaryBottomWidgetView)
        }
        
        if let middleLabelErrorString = middleLabelErrorString {
            middleLabel.text = middleLabelErrorString
            middleLabel.textColor = .errorText
        } else {
            middleLabel.text = middleLabelString
        }
    }
}
