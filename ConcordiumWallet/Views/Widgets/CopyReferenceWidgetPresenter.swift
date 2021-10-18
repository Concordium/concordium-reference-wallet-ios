//
//  CopyReferenceWidgetPresenter.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 08/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

// MARK: - Delegate
protocol CopyReferenceWidgetPresenterDelegate: AnyObject {
    func copyReferenceWidgetDidCopyReference()
}

// MARK: - Presenter
protocol CopyReferenceWidgetPresenterProtocol: AnyObject {
    var view: CopyReferenceWidgetViewProtocol? { get set }
    func viewDidLoad()
    func copyReferenceButtonTapped()
    var reference: String { get }
}

class CopyReferenceWidgetPresenter: CopyReferenceWidgetPresenterProtocol {
    
    var view: CopyReferenceWidgetViewProtocol?
    weak var delegate: CopyReferenceWidgetPresenterDelegate?
    var reference: String
        
    init(delegate: CopyReferenceWidgetPresenterDelegate, reference: String) {
        self.delegate = delegate
        self.reference = reference
    }
    
    func viewDidLoad() {}
    
    func copyReferenceButtonTapped() {
        let supportMailBody = String(
            format: "supportmail.body".localized,
            reference,
            AppSettings.appVersion,
            AppSettings.buildNumber,
            AppSettings.iOSVersion
        )
        
        CopyPasterHelper.copy(string: supportMailBody)
        view?.showToast()
        delegate?.copyReferenceWidgetDidCopyReference()
    }
}
