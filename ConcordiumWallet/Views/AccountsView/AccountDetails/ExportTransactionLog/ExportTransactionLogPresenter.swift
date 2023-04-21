//
//  ExportTransactionLogPresenter.swift
//  Mock
//
//  Created by Lars Christensen on 19/12/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit

protocol ExportTransactionLogPresenterDelegate: AnyObject {
    func saveTapped(url: URL, completion: @escaping (Bool) -> Void)
    func doneTapped()
}

class ExportTransactionLogPresenter: SwiftUIPresenter<ExportTransactionLogViewModel> {
    private let account: AccountDataType
    private weak var delegate: ExportTransactionLogPresenterDelegate?
    
    init(
        account: AccountDataType,
        delegate: ExportTransactionLogPresenterDelegate
    ) {
        self.account = account
        self.delegate = delegate
        super.init(viewModel: .init(account: account))
        
        viewModel.navigationTitle = "exporttransactionlog.navigationtitle".localized
    }
    
    override func receive(event: ExportTransactionLogEvent) {
        Task {
            switch event {
            case .save:
                delegate?.saveTapped(url: viewModel.getTempFileUrl(), completion: { success in
                    self.viewModel.deleteTempFile()
                    if success {
                        self.viewModel.saved()
                    }
                })
            case .done:
                delegate?.doneTapped()
            }
        }
    }
}
