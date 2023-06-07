//
//  WalletConnectApprovalViewController.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 07/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import UIKit

class WalletConnectApprovalViewController: UIViewController {

    let view: WalletConnectProposalApprovalView
    
    init(view: WalletConnectProposalApprovalView) {
        self.view = view
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwiftUIViewToController(view)
    }
}
