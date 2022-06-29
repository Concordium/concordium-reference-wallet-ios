//
//  TermsAndConditionsUpdatePresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 27/05/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

class TermsAndConditionsUpdatePresenter: TermsAndConditionsPresenterProtocol {
    weak var view: TermsAndConditionsViewProtocol?
    weak var delegate: TermsAndConditionsPresenterDelegate?
    
    init(delegate: TermsAndConditionsPresenterDelegate? = nil) {
        self.delegate = delegate
    }
    
    func viewDidLoad() {}
}
