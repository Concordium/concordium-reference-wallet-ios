//
//  AccountSelectViewController.swift
//  Mock
//
//  Created by Milan Sawicki on 01/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI
import UIKit

class WalletConnectAccountSelectViewController: UIViewController {
    private var accountSelectView: WalletConnectAccountSelectView
    init(viewModel: WalletConnectAccountSelectViewModel) {
        accountSelectView = WalletConnectAccountSelectView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "Method not implemented, please use init(_:StorageManagerProtocol).")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "walletconnect.select.account.title".localized
        addSwiftUIViewToController(accountSelectView)
    }
}
