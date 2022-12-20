//
//  ExportTransactionLogPresenter.swift
//  Mock
//
//  Created by Lars Christensen on 19/12/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol ExportTransactionLogPresenterDelegate: AnyObject {
    func finishedExportingTransactionLog()
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
            case .doneTapped:
                delegate?.finishedExportingTransactionLog()
            }
        }
    }
}
