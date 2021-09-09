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

    @IBOutlet weak var centerWidgetView: UIView!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var tertiaryLabel: UILabel!
    
    var topWidget: UIViewController?
    var primaryBottomWidget: UIViewController?
    var secondaryBottomWidget: UIViewController?
    var centerWidget: UIViewController?
    var primaryLabelString: String?
    var primaryLabelErrorString: String?
    var secondaryLabelString: String?
    var secondaryLabelButtonAction: (() -> Void)?
    var tertiaryLabelString: String?

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
        
        if let primaryLabelErrorString = primaryLabelErrorString {
            primaryLabel.text = primaryLabelErrorString
            primaryLabel.textColor = .errorText
        } else {
            primaryLabel.text = primaryLabelString
        }
        
        tertiaryLabel.text = tertiaryLabelString
        
        if let centerWidget = centerWidget {
            add(child: centerWidget, inside: centerWidgetView)
        }
    }
}
