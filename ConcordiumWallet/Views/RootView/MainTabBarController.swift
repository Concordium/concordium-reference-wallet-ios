//
//  MainTabBarController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 05/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class MainTabBarController: BaseTabBarController {

    let accountsCoordinator: AccountsCoordinator
    let identitiesCoordinator: IdentitiesCoordinator
    let moreCoordinator: MoreCoordinator

    init(accountsCoordinator: AccountsCoordinator, identitiesCoordinator: IdentitiesCoordinator,
         moreCoordinator: MoreCoordinator) {
        self.accountsCoordinator = accountsCoordinator
        self.identitiesCoordinator = identitiesCoordinator
        self.moreCoordinator = moreCoordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        accountsCoordinator.delegate = self
        accountsCoordinator.start()
        identitiesCoordinator.start()
        moreCoordinator.start()
        viewControllers = [accountsCoordinator.navigationController, identitiesCoordinator.navigationController, moreCoordinator.navigationController]
    }
}

extension MainTabBarController: AccountsCoordinatorDelegate {
    func createNewAccount() {
        selectedViewController = accountsCoordinator.navigationController
        accountsCoordinator.showCreateNewAccount()
    }

    func createNewIdentity() {
        selectedViewController = identitiesCoordinator.navigationController
        identitiesCoordinator.showCreateNewIdentity()
    }
    
    func noIdentitiesFound() {
        identitiesCoordinator.delegate?.noIdentitiesFound()
    }
    
    func showCreateNewIdentity() {
        selectedViewController = identitiesCoordinator.navigationController
        identitiesCoordinator.showCreateNewIdentity()
    }
    
    func displayNewTerms() {
        accountsCoordinator.showNewTerms()
    }
}
