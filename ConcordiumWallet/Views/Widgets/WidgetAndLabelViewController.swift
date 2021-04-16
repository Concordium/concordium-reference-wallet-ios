//
//  WidgetAndLabelViewController.swift
//  ConcordiumWallet
//
//  Created by Johan Rugager Vase on 22/06/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class WidgetAndLabelViewController: BaseViewController, Storyboarded {

    @IBOutlet weak var topWidgetView: UIView!
    @IBOutlet weak var bottomWidgetView: UIView!
    @IBOutlet weak var middleLabel: UILabel!
    
    var topWidget: UIViewController?
    var bottomWidget: UIViewController?
    var middleLabelString: String?
    var middleLabelErrorString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topWidget = topWidget {
            add(child: topWidget, inside: topWidgetView)
        }
        if let bottomWidget = bottomWidget {
            add(child: bottomWidget, inside: bottomWidgetView)
        }
        if let middleLabelErrorString = middleLabelErrorString {
            middleLabel.text = middleLabelErrorString
            middleLabel.textColor = .errorText
        } else {
            middleLabel.text = middleLabelString
        }
    }
}
