//
//  SingleLabelViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 22/06/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class SingleLabelFactory {
    class func create(stringValue: String) -> SingleLabelViewController {
        SingleLabelViewController.instantiate(fromStoryboard: "Widget") {coder in
            return SingleLabelViewController(coder: coder, stringValue: stringValue)
        }
    }
}
class SingleLabelViewController: UIViewController, Storyboarded {
    var stringValue: String

    @IBOutlet weak var label: UILabel! {
        didSet {
            label.text = stringValue
        }
    }
    
    init?(coder: NSCoder, stringValue: String) {
        self.stringValue = stringValue
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
