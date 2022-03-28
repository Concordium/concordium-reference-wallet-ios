//
//  StakeCoordinator.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 03/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

protocol DelegationCoordinatorDelegate: Coordinator {
    func finished()
}

class DelegationCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    weak var delegate: DelegationCoordinatorDelegate?
    private var account: AccountDataType
    
    private var dependencyProvider: StakeCoordinatorDependencyProvider
    private var delegationDataHandler: StakeDataHandler
    
    init(navigationController: UINavigationController, dependencyProvider: StakeCoordinatorDependencyProvider, account: AccountDataType, parentCoordinator: DelegationCoordinatorDelegate) {
        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
        self.account = account
        self.delegate = parentCoordinator
        self.delegationDataHandler = DelegationDataHandler(account: account, isRemoving: false)
    }
    
    func start() {
        if account.delegation == nil {
            showCarousel()
        } else {
            showStatus()
        }
    }

    func showCarousel() {
        let onboardingCarouselViewModel = OnboardingCarouselViewModel(
            title: "onboardingcarousel.registerdelegation.title".localized,
            pages: [
                OnboardingPage(
                    title: "onboardingcarousel.registerdelegation.page1.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "delegation_intro_flow_en_1")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.registerdelegation.page2.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "delegation_intro_flow_en_2")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.registerdelegation.page3.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "delegation_intro_flow_en_3")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.registerdelegation.page4.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "delegation_intro_flow_en_4")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.registerdelegation.page5.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "delegation_intro_flow_en_5")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.registerdelegation.page6.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "delegation_intro_flow_en_6")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.registerdelegation.page7.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "delegation_intro_flow_en_7")
                )
            ]
        )

        let onboardingCarouselPresenter = OnboardingCarouselPresenter(
            delegate: self,
            viewModel: onboardingCarouselViewModel
        )

        let onboardingCarouselViewController = OnboardingCarouselFactory.create(with: onboardingCarouselPresenter)
        onboardingCarouselViewController.hidesBottomBarWhenPushed = true

        navigationController.pushViewController(onboardingCarouselViewController, animated: true)
    }
    
    
    func showStatus() {
        //TODO: show status here and only show pool if the user chooses edit
        showPoolSelection()
    }
    
    func stopDelegation(cost: GTU, energy: Int) {
        self.delegationDataHandler = DelegationDataHandler(account: account, isRemoving: true)
        //TODO: show carousel and then ask for confirmation
        showRequestConfirmation(cost: cost, energy: energy)
    }
    
    
    
    func showAmountInput(bakerPoolResponse: BakerPoolResponse?) {
        let presenter = DelegationAmountInputPresenter(account: account, delegate: self, dependencyProvider: dependencyProvider, dataHandler: delegationDataHandler, bakerPoolResponse: bakerPoolResponse)
        let vc = StakeAmountInputFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showPoolSelection() {
        let presenter = DelegationPoolSelectionPresenter(delegate: self, dependencyProvider: dependencyProvider, dataHandler: delegationDataHandler)
        let vc = DelegationPoolSelectionFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showRequestConfirmation(cost: GTU,
                          energy: Int) {
        let presenter = DelegationReceiptConfirmationPresenter(account: account,
                                                               dependencyProvider: dependencyProvider,
                                                               delegate: self,
                                                               cost: cost,
                                                               
                                                               energy: energy,
                                                               dataHandler: delegationDataHandler)
        let vc = StakeReceiptFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSubmissionReceipt() {
        let presenter = DelegationReceiptPresenter(account: account, dependencyProvider: dependencyProvider, delegate: self, dataHandler: delegationDataHandler)
        let vc = StakeReceiptFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension DelegationCoordinator: DelegationAmountInputPresenterDelegate {
    //TODO: readd cleanup
//    func finishedDelegation() {
//        self.delegate?.finished()
//    }
    func finishedAmountInput(cost: GTU, energy: Int) {
        self.showRequestConfirmation(cost: cost, energy: energy)
    }
}

extension DelegationCoordinator: DelegationPoolSelectionPresenterDelegate {
    func finishedPoolSelection(bakerPoolResponse: BakerPoolResponse?) {
        showAmountInput(bakerPoolResponse: bakerPoolResponse)
    }
}

extension DelegationCoordinator: DelegationReceiptConfirmationPresenterDelegate {
    func confirmedTransaction() {
        self.showSubmissionReceipt()
    }
}

extension DelegationCoordinator: DelegationReceiptPresenterDelegate {
    func finishedShowingReceipt() {
        self.navigationController.popToRootViewController(animated: true)
    }
}

extension DelegationCoordinator: RequestPasswordDelegate {
    
}

extension DelegationCoordinator: OnboardingCarouselPresenterDelegate {
    func onboardingCarouselClosed() {
        self.navigationController.popViewController(animated: true)
        self.delegate?.finished()
    }
    
    func onboardingCarouselSkiped() {
        showPoolSelection()
    }
    
    func onboardingCarouselFinished() {
        showPoolSelection()
    }
}
