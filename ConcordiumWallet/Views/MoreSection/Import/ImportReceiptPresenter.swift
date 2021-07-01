//
//  ImportReceiptPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/09/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: -
// MARK: Delegate
protocol ImportReceiptPresenterDelegate: AnyObject {
    func importReceiptDidFinish()
}

// MARK: -
// MARK: Presenter
protocol ImportReceiptPresenterProtocol: AnyObject {
	var view: ImportReceiptViewProtocol? { get set }
    func viewDidLoad()
    func okButtonPressed()
}

class ImportReceiptPresenter: ImportReceiptPresenterProtocol {

    weak var view: ImportReceiptViewProtocol?
    weak var delegate: ImportReceiptPresenterDelegate?

    init(delegate: ImportReceiptPresenterDelegate? = nil) {
        self.delegate = delegate
    }

    func viewDidLoad() {
    }
    
    func okButtonPressed() {
        delegate?.importReceiptDidFinish()
    }
}
