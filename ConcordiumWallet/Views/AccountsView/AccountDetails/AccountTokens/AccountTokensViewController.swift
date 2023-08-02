//
//  AccountTokensViewController.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 02/08/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import UIKit

class AccountTokensViewController: UIViewController, Storyboarded {
    @IBOutlet weak var ourLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        ourLabel.text = "Hello"
    }
}
