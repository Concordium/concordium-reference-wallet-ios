//
//  RecoveryPhraseGettingStartedPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol RecoveryPhraseGettingStartedPresenterDelegate: AnyObject {
    func setupNewWallet(with recoveryPhrase: RecoveryPhrase)
    func recoverWallet()
}

class RecoveryPhraseGettingStartedPresenter: SwiftUIPresenter<RecoveryPhraseGettingStartedViewModel> {
    private let longPressesTimeTresholdDifference = 1.0
    
    private weak var delegate: RecoveryPhraseGettingStartedPresenterDelegate?
    private let recoveryPhraseService: RecoveryPhraseServiceProtocol
    
    var createNewWalletDemoMode: Bool {
        didSet {
            viewModel.demoMode = createNewWalletDemoMode && recoverWalletDemoMode
        }
    }
    
    var recoverWalletDemoMode: Bool {
        didSet {
            viewModel.demoMode = createNewWalletDemoMode && recoverWalletDemoMode
        }
    }
    
    init(
        recoveryPhraseService: RecoveryPhraseServiceProtocol,
        delegate: RecoveryPhraseGettingStartedPresenterDelegate
    ) {
        self.recoveryPhraseService = recoveryPhraseService
        self.delegate = delegate
        self.createNewWalletDemoMode = false
        self.recoverWalletDemoMode = false
        
        super.init(
            viewModel: .init(
                title: "recoveryphrase.gettingstarted.title".localized,
                createNewWalletSection: .init(
                    title: "recoveryphrase.gettingstarted.new.title".localized,
                    body: "recoveryphrase.gettingstarted.new.body".localized,
                    buttonTitle: "recoveryphrase.gettingstarted.new.buttontitle".localized
                ),
                recoverWalletSection: .init(
                    title: "recoveryphrase.gettingstarted.recover.title".localized,
                    body: "recoveryphrase.gettingstarted.recover.body".localized,
                    buttonTitle: "recoveryphrase.gettingstarted.recover.buttontitle".localized
                )
            )
        )
        
        viewModel.navigationTitle = "recoveryphrase.gettingstarted.navigationtitle".localized
    }
    
    override func receive(event: RecoveryPhraseGettingStartedEvent) {
        switch event {
        case .createNewWallet:
            if let delegate = delegate {
                switch recoveryPhraseService.generateRecoveryPhrase() {
                case let .failure(error):
                    if !GeneralError.isGeneralError(.userCancelled, error: error) {
                        self.viewModel.alertPublisher.send(.error(ErrorMapper.toViewError(error: error)))
                    }
                case let .success(recoveryPhrase):
                    delegate.setupNewWallet(with: recoveryPhrase)
                }
            }
        case .recoverWallet:
            delegate?.recoverWallet()
        case .createNewWalletDemoMode:
            #if MAINNET
            if UserDefaults.bool(forKey: "demomode.userdefaultskey".localized) == false {
                createNewWalletDemoMode = true
                DispatchQueue.main.asyncAfter(deadline: .now() + longPressesTimeTresholdDifference) {
                    if self.recoverWalletDemoMode == false {
                        self.createNewWalletDemoMode = false
                    }
                }
            }
            #endif
        case .recoverWalletDemoMode:
            #if MAINNET
            if UserDefaults.bool(forKey: "demomode.userdefaultskey".localized) == false {
                recoverWalletDemoMode = true
                DispatchQueue.main.asyncAfter(deadline: .now() + longPressesTimeTresholdDifference) {
                    if self.createNewWalletDemoMode == false {
                        self.recoverWalletDemoMode = false
                    }
                }
            }
            #endif
        case .enterDemoMode:
            // Enter demo mode
            UserDefaults.setBool(true, forKey: "demomode.userdefaultskey".localized)
            
            createNewWalletDemoMode = false
            recoverWalletDemoMode = false
        case .cancelDemoMode:
            createNewWalletDemoMode = false
            recoverWalletDemoMode = false
        }
    }
}
