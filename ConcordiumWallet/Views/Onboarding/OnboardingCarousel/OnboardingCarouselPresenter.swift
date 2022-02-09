//
//  OnboardingCarouselPresenter.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 08/02/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

struct OnboardingPage {
    let title: String
    let viewController: UIViewController
}

struct OnboardingCarouselViewModel {
    let pages: [OnboardingPage]
}

protocol OnboardingCarouselViewProtocol: AnyObject {
    func bind(to viewModel: OnboardingCarouselViewModel)
}

protocol OnboardingCarouselPresenterDelegate: AnyObject {
    func onboardingCarouselSkiped()
    func onboardingCarouselFinished()
}

protocol OnboardingCarouselPresenterProtocol: AnyObject {
    var view: OnboardingCarouselViewProtocol? { get set }
    func viewDidLoad()

    func userTappedSkip()
    func userTappedContinue()
}

final class OnboardingCarouselPresenter: OnboardingCarouselPresenterProtocol {

    weak var view: OnboardingCarouselViewProtocol?
    weak var delegate: OnboardingCarouselPresenterDelegate?

    private var viewModel: OnboardingCarouselViewModel

    init(delegate: OnboardingCarouselPresenterDelegate, viewModel: OnboardingCarouselViewModel) {
        self.delegate = delegate
        self.viewModel = viewModel
    }

    func viewDidLoad() {
        view?.bind(to: viewModel)
    }

    func userTappedSkip() {
        delegate?.onboardingCarouselSkiped()
    }

    func userTappedContinue() {
        delegate?.onboardingCarouselFinished()
    }
}
