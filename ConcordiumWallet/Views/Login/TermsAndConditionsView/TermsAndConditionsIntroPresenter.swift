//
//  TermsAndConditionsIntroPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 27/05/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine
import UIKit

class TermsAndConditionsIntroPresenter: TermsAndConditionsPresenterProtocol {
    weak var view: TermsAndConditionsViewProtocol?
    weak var delegate: TermsAndConditionsPresenterDelegate?
    
    private weak var appSettingsDelegate: AppSettingsDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        delegate: TermsAndConditionsPresenterDelegate? = nil,
        appSettingsDelegate: AppSettingsDelegate?
    ) {
        self.delegate = delegate
        self.appSettingsDelegate = appSettingsDelegate
    }
    
    func viewDidLoad() {
        appSettingsDelegate?.checkForAppSettings()
    }
}
