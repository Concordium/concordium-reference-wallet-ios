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
        let seedIdentitiesCoordinator = SeedIdentitiesCoordinator(
            navigationController: BaseNavigationController(),
            action: .createIdentity,
            dependencyProvider: dependencyProvider,
            delegate: self
        )
        
        childCoordinators.append(seedIdentitiesCoordinator)
        seedIdentitiesCoordinator.start()
        navigationController.present(seedIdentitiesCoordinator.navigationController, animated: true)
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

extension IdentitiesCoordinator: SeedIdentitiesCoordinatorDelegate {
    func seedIdentityCoordinatorWasFinished(for identity: IdentityDataType) {
        navigationController.dismiss(animated: true)
        childCoordinators.removeAll(where: { $0 is SeedIdentitiesCoordinator })
        
        let identityDict = ["identity" : identity]
        NotificationCenter.default.post(name: Notification.Name("seedIdentityCoordinatorWasFinishedNotification"), object: nil, userInfo: identityDict)
    }
}
