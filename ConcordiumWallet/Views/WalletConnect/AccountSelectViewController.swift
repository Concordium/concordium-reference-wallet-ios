//
//  AccountSelectViewController.swift
//  Mock
//
//  Created by Milan Sawicki on 01/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import UIKit

import SwiftUI
import UIKit

class AccountSelectViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let accountSelectView = AccountSelectSwiftUIView()
        let hostingController = UIHostingController(rootView: accountSelectView)
        addChild(hostingController)
        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)
    }
}

// SwiftUI view
struct AccountSelectSwiftUIView: View {
    @EnvironmentObject var accountData: AccountData // Access the published accounts array

    var body: some View {
        List(accountData.accounts, id: \.address) { account in
            Text(account.address)
        }
    }
}

class AccountData: ObservableObject {
    
    @Published var accounts: [AccountDataType] = []
}
