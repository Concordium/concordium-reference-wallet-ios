//
//  DelegationOnboardingCoordinator.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 04/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit

enum DelegationOnboardingMode {
    case register
    case update
    case remove(cost: GTU, energy: Int)
}
protocol DelegationOnboardingCoordinatorDelegate: Coordinator {
    func finished(mode: DelegationOnboardingMode)
    func closed()
}

class DelegationOnboardingCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var mode: DelegationOnboardingMode
    weak var delegate: DelegationOnboardingCoordinatorDelegate?
    
    init(navigationController: UINavigationController,
         parentCoordinator: DelegationOnboardingCoordinatorDelegate,
         mode: DelegationOnboardingMode) {
        self.navigationController = navigationController
        self.delegate = parentCoordinator
        self.mode = mode
    }
    func start() {
        switch mode {
        case .register:
            showIntroCarousel()
        case .update:
            showUpdateCarousel()
        case .remove:
            showRemoveCarousel()
        }
    }
    
    func showIntroCarousel() {
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
    
    func showUpdateCarousel() {
        let onboardingCarouselViewModel = OnboardingCarouselViewModel(
            title: "onboardingcarousel.updatedelegation.title".localized,
            pages: [
                OnboardingPage(
                    title: "onboardingcarousel.updatedelegation.page1.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "delegation_update_flow_en_1")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.updatedelegation.page2.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "delegation_update_flow_en_2")),
                OnboardingPage(
                    title: "onboardingcarousel.updatedelegation.page3.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "delegation_update_flow_en_3")
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
    func showRemoveCarousel() {
        let onboardingCarouselViewModel = OnboardingCarouselViewModel(
            title: "onboardingcarousel.removedelegation.title".localized,
            pages: [
                OnboardingPage(
                    title: "onboardingcarousel.removedelegation.page1.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "delegation_remove_flow_en_1")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.removedelegation.page2.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "delegation_remove_flow_en_2")
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
}
extension DelegationOnboardingCoordinator: OnboardingCarouselPresenterDelegate {
    func onboardingCarouselClosed() {
        self.navigationController.popViewController(animated: true)
        self.delegate?.closed()
    }
    
    func onboardingCarouselSkiped() {
        self.delegate?.finished(mode: self.mode)
    }
    
    func onboardingCarouselFinished() {
        self.delegate?.finished(mode: self.mode)
    }
}
