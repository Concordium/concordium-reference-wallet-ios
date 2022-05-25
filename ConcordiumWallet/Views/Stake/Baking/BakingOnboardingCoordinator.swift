//
//  BakingOnboardingCoordinator.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 20/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit

enum BakingOnboardingMode {
    case register
    case updateStake
    case updatePoolSettings
    case updateKeys
    case remove
}
protocol BakingOnboardingCoordinatorDelegate: Coordinator {
    func finished(dataHandler: StakeDataHandler)
    func closed()
}

class BakingOnboardingCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private let dataHandler: StakeDataHandler
    weak var delegate: BakingOnboardingCoordinatorDelegate?
    
    init(
        navigationController: UINavigationController,
        parentCoordinator: BakingOnboardingCoordinatorDelegate,
        dataHandler: StakeDataHandler
    ) {
        self.navigationController = navigationController
        self.delegate = parentCoordinator
        self.dataHandler = dataHandler
    }
    
    func start() {
        switch dataHandler.transferType {
        case .registerBaker:
            showIntroCarousel()
        case .updateBakerStake, .updateBakerPool, .updateBakerKeys:
            showUpdateCarousel()
        case .removeBaker:
            showRemoveCarousel()
        default:
            self.delegate?.closed()
        }
    }
    
    func showIntroCarousel() {
        let onboardingCarouselViewModel = OnboardingCarouselViewModel(
            title: "onboardingcarousel.registerbaker.title".localized,
            pages: [
                OnboardingPage(
                    title: "onboardingcarousel.registerbaker.page1.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "baker_intro_flow_en_1")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.registerbaker.page2.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "baker_intro_flow_en_2")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.registerbaker.page3.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "baker_intro_flow_en_3")
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
            title: "onboardingcarousel.updatebaker.title".localized,
            pages: [
                OnboardingPage(
                    title: "onboardingcarousel.updatebaker.page1.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "baker_update_flow_en_1")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.updatebaker.page2.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "baker_update_flow_en_2")),
                OnboardingPage(
                    title: "onboardingcarousel.updatebaker.page3.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "baker_update_flow_en_3")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.updatebaker.page4.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "baker_update_flow_en_4")),
                OnboardingPage(
                    title: "onboardingcarousel.updatebaker.page5.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "baker_update_flow_en_5")
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
            title: "onboardingcarousel.removebaker.title".localized,
            pages: [
                OnboardingPage(
                    title: "onboardingcarousel.removebaker.page1.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "baker_remove_flow_en_1")
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
extension BakingOnboardingCoordinator: OnboardingCarouselPresenterDelegate {
    func onboardingCarouselClosed() {
        self.navigationController.popViewController(animated: true)
        self.delegate?.closed()
    }
    
    func onboardingCarouselSkiped() {
        self.delegate?.finished(dataHandler: self.dataHandler)
    }
    
    func onboardingCarouselFinished() {
        self.delegate?.finished(dataHandler: self.dataHandler)
    }
}
