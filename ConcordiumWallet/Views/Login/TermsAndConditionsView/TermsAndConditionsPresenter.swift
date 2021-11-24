//
//  TermsAndConditionsPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 17/05/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

// MARK: View
protocol TermsAndConditionsViewProtocol: ShowAlert {
}

protocol TermsAndConditionsPresenterProtocol: AnyObject {
    var view: TermsAndConditionsViewProtocol? { get set }
    func userTappedAcceptTerms()
}

// MARK: Delegate
protocol TermsAndConditionsPresenterDelegate: AnyObject {
    func userTappedAcceptTerms()
}

class TermsAndConditionsPresenter {
    weak var view: TermsAndConditionsViewProtocol?
    weak var delegate: TermsAndConditionsPresenterDelegate?

    init(delegate: TermsAndConditionsPresenterDelegate? = nil) {
        self.delegate = delegate
    }
}

extension TermsAndConditionsPresenter: TermsAndConditionsPresenterProtocol {
    func userTappedAcceptTerms() {
        //save the hash of the accepted terms
        AppSettings.termsHash = HashingHelper.hash(AppSettings.currentTerms)
        self.delegate?.userTappedAcceptTerms()
    }
}
