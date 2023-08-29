//
//  RecoveryPhraseInputPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol RecoveryPhraseInputPresenterDelegate: AnyObject {
    func phraseInputReceived(validPhrase: RecoveryPhrase)
}

class RecoveryPhraseInputPresenter: SwiftUIPresenter<RecoveryPhraseInputViewModel> {
    private let recoveryService: RecoveryPhraseServiceProtocol
    private weak var delegate: RecoveryPhraseInputPresenterDelegate?
    
    init(
        recoveryService: RecoveryPhraseServiceProtocol,
        delegate: RecoveryPhraseInputPresenterDelegate
    ) {
        self.recoveryService = recoveryService
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
                title: "recoveryphrase.recover.input.title".localized,
                clearAll: "recoveryphrase.recover.input.clearall".localized,
                clearBelow: "recoveryphrase.recover.input.clearbelow".localized,
                selectedWords: Array(repeating: "", count: 24),
                currentInput: "",
                currentSuggestions: [],
                error: nil
            )
        )
        
        viewModel.navigationTitle = "recoveryphrase.recover.input.navigationtitle".localized
        
        viewModel.$currentInput.sink { [weak self] word in
            if word.count > 1 {
                self?.viewModel.currentSuggestions = recoveryService.suggestions(for: word)
            } else {
                self?.viewModel.currentSuggestions = []
            }
        }.store(in: &cancellables)
    }
    
    override func receive(event: RecoveryPhraseInputEvent) {
        switch event {
        case .clearAll:
            viewModel.selectedWords = Array(repeating: "", count: 24)
            viewModel.currentSuggestions = []
        case .clearBelow(let index):
            viewModel.selectedWords = viewModel.selectedWords[0...index] + Array(repeating: "", count: 23 - index)
        case .wordSelected(let index, let word):
            // TODO: Test phrase
//            viewModel.selectedWords = ["interest", "spy", "champion", "install", "appear", "solution", "digital", "intact", "expose", "order", "minute", "match", "train", "possible", "practice", "leave", "first", "matter", "zero", "brief", "tag", "mushroom", "anger", "tide"]
//            viewModel.selectedWords = ["there", "excuse", "hat", "credit", "position", "various", "laptop", "arch", "fish", "tank", "mass", "margin", "sea", "purity", "position", "royal", "law", "tribe", "harvest", "match", "field", "hundred", "unfair", "increase"]
//            viewModel.selectedWords = ["myth", "hamster", "wire", "envelope", "shine", "client", "host", "flat", "burden", "photo", "west", "say", "bench", "hawk", "faith", "tower", "track", "wealth", "ceiling", "lemon", "net", "bring", "noble", "script"]
//            viewModel.selectedWords = ["congress", "test", "genre", "day", "monitor", "divorce", "heart", "balance", "destroy", "save", "upgrade", "cash", "weird", "process", "wreck", "donor", "copy", "potato", "try", "essay", "impulse", "myself", "chimney", "pipe"]
            
            viewModel.selectedWords = ["front", "ethics", "seat", "garlic", "alone", "diesel", "discover", "same", "shadow", "grace", "dentist", "attitude", "skill", "blanket", "flat", "skill", "avocado", "manage", "vicious", "dynamic", "hire", "elevator", "fee", "price"]
//            viewModel.selectedWords[index] = word
            if viewModel.selectedWords.allSatisfy({ !$0.isEmpty }) {
                switch recoveryService.validate(recoveryPhrase: viewModel.selectedWords) {
                case let .success(recoveryPhrase):
                    delegate?.phraseInputReceived(validPhrase: recoveryPhrase)
                case .failure:
                    viewModel.error = "recoveryphrase.recover.input.validationerror".localized
                }
            }
        }
    }
}
