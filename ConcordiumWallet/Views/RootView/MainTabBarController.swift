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
    let moreCoordinator: MoreCoordinator

    // Override selectedViewController for User initiated changes
    override var selectedViewController: UIViewController? {
        didSet {
            // if the selectedViewController is not a navigationController, it means it is the export tab
            // switch to the morecoordinator and display the export screen
            if !(selectedViewController is UINavigationController) {
                selectedViewController = moreCoordinator.navigationController
                moreCoordinator.showExport()
            }
        }
    }
    
    init(accountsCoordinator: AccountsCoordinator,
         moreCoordinator: MoreCoordinator) {
        self.accountsCoordinator = accountsCoordinator
  
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
       
        let exportVC = UIViewController() // this will never be shown - we just use it to have a tab
        exportVC.tabBarItem = UITabBarItem(title: "backup_tab_title".localized, image: UIImage(named: "tab_bar_backup_icon"), tag: 0)
        moreCoordinator.start()
        viewControllers = [exportVC, accountsCoordinator.navigationController, moreCoordinator.navigationController]
        selectedViewController = accountsCoordinator.navigationController
    }
}

extension MainTabBarController: AccountsCoordinatorDelegate {
    func showIdentities() {
        selectedViewController = moreCoordinator.navigationController
        moreCoordinator.navigationController.popToRootViewController(animated: false)
        moreCoordinator.showIdentities()
    }
    
    func createNewAccount() {
        selectedViewController = accountsCoordinator.navigationController
        accountsCoordinator.showCreateNewAccount()
    }

    func createNewIdentity() {
        selectedViewController = moreCoordinator.navigationController
        moreCoordinator.showCreateNewIdentity()
    }
    
    func noIdentitiesFound() {
        moreCoordinator.delegate?.noIdentitiesFound()
    }
    
    func showCreateNewIdentity() {
        selectedViewController = moreCoordinator.navigationController
        moreCoordinator.showCreateNewIdentity()
    }
}

extension MainTabBarController: ImportExport {
    func showImport() {
        selectedViewController = moreCoordinator.navigationController
        moreCoordinator.showImport()
    }

    func showExport() {
        selectedViewController = moreCoordinator.navigationController
        moreCoordinator.showExport()
    }
}
