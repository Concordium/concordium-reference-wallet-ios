//
//  TermsAndConditionsPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 17/05/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import MessageUI

// MARK: View
protocol TermsAndConditionsViewProtocol: ShowAlert {
}

protocol TermsAndConditionsPresenterProtocol: AnyObject {
    var view: TermsAndConditionsViewProtocol? { get set }
    var delegate: TermsAndConditionsPresenterDelegate? { get set }
    func userTappedAcceptTerms()
    func viewDidLoad()
}

// MARK: Delegate
protocol TermsAndConditionsPresenterDelegate: AnyObject {
    func userTappedAcceptTerms()
}

extension TermsAndConditionsPresenterProtocol {
    func userTappedAcceptTerms() {
        // save the hash of the accepted terms
        AppSettings.acceptedTermsHash = HashingHelper.hash(TermsHelper.currentTerms)
        self.delegate?.userTappedAcceptTerms()
    }
}
