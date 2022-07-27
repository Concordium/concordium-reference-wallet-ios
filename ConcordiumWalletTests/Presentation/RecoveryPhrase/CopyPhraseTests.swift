//
//  CopyPhraseTests.swift
//  ConcordiumWalletTests
//
//  Created by Niels Christian Friis Jakobsen on 01/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import XCTest
import Combine
@testable import Mock

class CopyPhraseTests: XCTestCase {
    func test_phrase_is_initially_hidden() {
        let (presenter, _) = createPresenter()
        
        XCTAssert(presenter.viewModel.recoveryPhrase.isHidden)
        XCTAssertFalse(presenter.viewModel.hasCopiedPhrase)
    }
    
    func test_confirm_box_can_be_toggled() {
        let (presenter, _) = createPresenter()
        
        XCTAssertFalse(presenter.viewModel.hasCopiedPhrase)
        
        presenter.viewModel.send(.confirmBoxTapped)
        
        XCTAssert(presenter.viewModel.hasCopiedPhrase)
        
        presenter.viewModel.send(.confirmBoxTapped)
        
        XCTAssertFalse(presenter.viewModel.hasCopiedPhrase)
    }
    
    func test_confirm_box_must_be_checked_before_finishing() {
        let (presenter, delegate) = createPresenter()
        
        presenter.viewModel.send(.continueTapped)
        
        XCTAssertFalse(delegate.hasCalledFinish)
        
        presenter.viewModel.send(.confirmBoxTapped)
        presenter.viewModel.send(.continueTapped)
        
        XCTAssert(delegate.hasCalledFinish)
    }
    
    func test_words_are_revealed_when_requested() {
        let (presenter, _) = createPresenter()
        
        presenter.viewModel.send(.showPhrase)
        
        XCTAssertEqual(presenter.viewModel.recoveryPhrase, .shown(words: testWords))
    }
    
    private func createPresenter() -> (RecoveryPhraseCopyPhrasePresenter, TestDelegate) {
        let delegate = TestDelegate()
        let presenter = RecoveryPhraseCopyPhrasePresenter(words: testWords, delegate: delegate)
        
        return (presenter, delegate)
    }
    
    private var testWords = [
        "clay", "vehicle", "crane", "debris", "usual", "canal",
        "puzzle", "concert", "asset", "render", "post", "cherry",
        "voyage", "original", "enrich", "gain", "basket", "dust",
        "version", "become", "desk", "oxygen", "doctor", "idea"
    ]
}

private class TestDelegate: RecoveryPhraseCopyPhrasePresenterDelegate {
    var hasCalledFinish = false
    
    func finishedCopyingPhrase() {
        hasCalledFinish = true
    }
}

private extension RecoveryPhraseState {
    var isHidden: Bool {
        switch self {
        case .shown:
            return false
        case .hidden:
            return true
        }
    }
}
