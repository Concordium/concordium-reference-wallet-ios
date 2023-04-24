//
//  ExportPrivateKeyViewModel.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 15.12.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum ExportPrivateKeyEvent {
    case showPrivateKey
    case copyTapped
    case exportTapped
    case doneTapped
}

enum ExportPrivateKeyState: Equatable {
    case hidden(topMessage: String, downMessage: String)
    case shown(privateKey: String, topMessage: String, exportButtonTitle: String)
}

struct AlertText: Identifiable {
    var id: String { text }
    let text: String
}

class ExportPrivateKeyViewModel: PageViewModel<ExportPrivateKeyEvent> {
    @Published var title: String
    @Published var exportPrivateKey: ExportPrivateKeyState
    @Published var doneButtonTitle: String
    @Published var alertText: AlertText?
    
    init(
        title: String,
        exportPrivateKey: ExportPrivateKeyState,
        doneButtonTitle: String
    ) {
        self.title = title
        self.exportPrivateKey = exportPrivateKey
        self.doneButtonTitle = doneButtonTitle
        self.alertText = nil
    }
}
