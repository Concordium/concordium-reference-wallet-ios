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
    var copyableReference: String { get }
}

class CopyReferenceWidgetPresenter: CopyReferenceWidgetPresenterProtocol {
    
    var view: CopyReferenceWidgetViewProtocol?
    var copyableReference: String
    weak var delegate: CopyReferenceWidgetPresenterDelegate?

    init(delegate: CopyReferenceWidgetPresenterDelegate, copyableReference: String) {
        self.delegate = delegate
        self.copyableReference = copyableReference
    }
    
    func viewDidLoad() {}
    
    func copyReferenceButtonTapped() {
        CopyPasterHelper.copy(string: copyableReference)
        view?.showToast(with: copyableReference)
        delegate?.copyReferenceWidgetDidCopyReference()
    }
}
