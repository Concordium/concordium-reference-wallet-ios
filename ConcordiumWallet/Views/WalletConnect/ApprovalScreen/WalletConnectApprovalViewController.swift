//
//  WalletConnectApprovalViewController.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 07/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import UIKit

class WalletConnectApprovalViewController: UIViewController {

    var contentView: WalletConnectProposalApprovalView

    init(contentView: WalletConnectProposalApprovalView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "Method not implemented, please use init(_:StorageManagerProtocol).")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwiftUIViewToController(contentView)
    }
}
