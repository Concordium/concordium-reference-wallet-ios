//
//  IdentitiesCoordinator.swift
//  ConcordiumWallet
//
//  Created by Concordium on 05/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

protocol IdentitiesCoordinatorDelegate: AnyObject {
    func noIdentitiesFound()
    func finishedDisplayingIdentities()
}

class IdentitiesCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    private var dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider
    weak var delegate: IdentitiesCoordinatorDelegate?
    init(navigationController: UINavigationController,
         dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider,
         parentCoordinator: IdentitiesCoordinatorDelegate) {

        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
        self.delegate = parentCoordinator
    }

    func start() {
        showInitial()
    }

    func showInitial(animated: Bool = false) {
        let identitiesPresenter = IdentitiesPresenter(dependencyProvider: dependencyProvider, delegate: self)
        let vc = IdentitiesFactory.create(with: identitiesPresenter, flow: .show)
        vc.tabBarItem = UITabBarItem(title: "identities_tab_title".localized, image: UIImage(named: "tab_bar_identities_icon"), tag: 0)
        navigationController.pushViewController(vc, animated: animated)
    }

    func showIdentity(identity: IdentityDataType) {
        let identityBaseInfoWidgetViewController = IdentityBaseInfoWidgetFactory.create(with: IdentityBaseInfoWidgetPresenter(identity: identity))
        let topVc: UIViewController
        if identity.state == IdentityState.confirmed {
            let vc = WidgetViewController.instantiate(fromStoryboard: "Widget")
            let identityDataWidgetViewController = IdentityDataWidgetFactory.create(with: IdentityDataWidgetPresenter(identity: identity))
            vc.add(viewControllers: [identityBaseInfoWidgetViewController, identityDataWidgetViewController])
            topVc = vc
        } else if identity.state == IdentityState.pending {
            let vc = WidgetAndLabelViewController.instantiate(fromStoryboard: "Widget")
            vc.primaryLabelString = "identityPage.pendingExplanation".localized
            vc.topWidget = identityBaseInfoWidgetViewController
            topVc = vc
        } else {
            let vc = WidgetAndLabelViewController.instantiate(fromStoryboard: "Widget")
            vc.primaryLabelErrorString = identity.identityCreationError
            vc.topWidget = identityBaseInfoWidgetViewController
            
            let deleteIdentityButtonWidgetPresenter = DeleteIdentityButtonWidgetPresenter(
                identity: identity,
                dependencyProvider: dependencyProvider,
                delegate: self
            )
            
            vc.primaryBottomWidget = DeleteIdentityButtonWidgetFactory.create(with: deleteIdentityButtonWidgetPresenter)
            
            if let reference = identity.hashedIpStatusUrl {
                vc.tertiaryLabelString = "identityCreation.automaticAccountRemoval.text".localized
                                
                let copyReferenceWidgetPresenter = CopyReferenceWidgetPresenter(
                    delegate: self,
                    reference: reference
                )
                
                vc.secondaryCenterWidget = CopyReferenceWidgetFactory.create(with: copyReferenceWidgetPresenter)
            }
            
            if MailHelper.canSendMail {
                let contactSupportButtonWidgetPresenter = ContactSupportButtonWidgetPresenter(identity: identity, delegate: self)
                vc.secondaryBottomWidget = ContactSupportButtonWidgetFactory.create(with: contactSupportButtonWidgetPresenter)
            } else {
                let identityProviderName = identity.identityProviderName ?? ""
                // if no ip support email is present, we use Concordium's
                let identityProviderSupportEmail = identity.identityProvider?.support ?? AppConstants.Support.concordiumSupportMail
                let copyReferenceInfoWidgetPresenter = CopyReferenceInfoWidgetPresenter(identityProviderName: identityProviderName,
                                                                                        identityProviderSupportEmail: identityProviderSupportEmail)
                vc.primaryCenterWidget = CopyReferenceInfoWidgetFactory.create(with: copyReferenceInfoWidgetPresenter)
            }
            
            topVc = vc
        }
        topVc.title = "identityData.title".localized
        navigationController.pushViewController(topVc, animated: true)
    }

    func showCreateNewIdentity() {
        let createIdentityCoordinator = CreateIdentityCoordinator(navigationController: BaseNavigationController(),
                dependencyProvider: dependencyProvider, parentCoordinator: self)
        childCoordinators.append(createIdentityCoordinator)
        createIdentityCoordinator.start()
        navigationController.present(createIdentityCoordinator.navigationController, animated: true, completion: nil)
    }
    
    func showPreventIdentityCreationAlert() {
        let alert = UIAlertController(
            title: "identityCreation.prevent.title".localized,
            message: "identityCreation.prevent.message".localized,
            preferredStyle: .alert
        )
        
        let downloadAction = UIAlertAction(
            title: "identityCreation.prevent.button.download".localized,
            style: .default
        ) { _ in
            var appStoreUrl = "https://testflight.apple.com/join/YaKKqYMA"
            #if MAINNET
                appStoreUrl = "https://apps.apple.com/us/app/concordium-blockchain-wallet/id6444703764"
            #endif
            UIApplication.shared.open(URL(string: appStoreUrl)!, options: [:], completionHandler: nil)
        }
        
        let okAction = UIAlertAction(title: "identityCreation.prevent.button.okay".localized, style: .default)
        
        alert.addAction(downloadAction)
        alert.addAction(okAction)

        navigationController.present(alert, animated: true)
    }
}

extension IdentitiesCoordinator: CreateNewIdentityDelegate {
    func createNewIdentityFinished() {
        navigationController.dismiss(animated: true)
        childCoordinators.removeAll(where: { $0 is CreateIdentityCoordinator })
    }

    func createNewIdentityCancelled() {
        navigationController.dismiss(animated: true)
        childCoordinators.removeAll(where: { $0 is CreateIdentityCoordinator })
    }
}

extension IdentitiesCoordinator: IdentitiesPresenterDelegate {
    func identitySelected(identity: IdentityDataType) {
        showIdentity(identity: identity)
    }

    func createIdentitySelected() {
        showCreateNewIdentity()
    }
    
    func noValidIdentitiesAvailable() {
        self.delegate?.noIdentitiesFound()
    }
    
    func tryAgainIdentity() {
        showCreateNewIdentity()
    }
    
    func finishedPresentingIdentities() {
        self.delegate?.finishedDisplayingIdentities()
    }
    
    func preventIdentityCreationAlert() {
        self.showPreventIdentityCreationAlert()
    }
}

extension IdentitiesCoordinator: DeleteIdentityButtonWidgetPresenterDelegate {
    func deleteIdentityButtonWidgetDidDelete() {
        navigationController.popViewController(animated: true)
    }
}

extension IdentitiesCoordinator: ContactSupportButtonWidgetPresenterDelegate {
    func contactSupportButtonWidgetDidContactSupport() {}
}

extension IdentitiesCoordinator: CopyReferenceWidgetPresenterDelegate {
    func copyReferenceWidgetDidCopyReference() {}
}
