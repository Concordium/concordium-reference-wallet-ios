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
    func test_phrase_is_initially_hidden() throws {
        let (presenter, _) = try createPresenter()
        
        XCTAssert(presenter.viewModel.recoveryPhrase.isHidden)
        XCTAssertFalse(presenter.viewModel.hasCopiedPhrase)
    }
    
    func test_confirm_box_can_be_toggled_after_showing_words() throws {
        let (presenter, _) = try createPresenter()
        
        XCTAssertFalse(presenter.viewModel.hasCopiedPhrase)
        
        presenter.viewModel.send(.confirmBoxTapped)
        
        XCTAssertFalse(presenter.viewModel.hasCopiedPhrase)
        
        presenter.viewModel.send(.showPhrase)
        presenter.viewModel.send(.confirmBoxTapped)
        
        XCTAssert(presenter.viewModel.hasCopiedPhrase)
        
        presenter.viewModel.send(.confirmBoxTapped)
        
        XCTAssertFalse(presenter.viewModel.hasCopiedPhrase)
    }
    
    func test_confirm_box_must_be_checked_before_finishing() throws {
        let (presenter, delegate) = try createPresenter()
        
        presenter.viewModel.send(.continueTapped)
        
        XCTAssertNil(delegate.finishedPhrase)
        
        presenter.viewModel.send(.showPhrase)
        presenter.viewModel.send(.confirmBoxTapped)
        presenter.viewModel.send(.continueTapped)
        
        XCTAssertEqual(delegate.finishedPhrase, try testPhrase)
    }
    
    func test_words_are_revealed_when_requested() throws {
        let (presenter, _) = try createPresenter()
        
        presenter.viewModel.send(.showPhrase)
        
        XCTAssertEqual(presenter.viewModel.recoveryPhrase, .shown(recoveryPhrase: try testPhrase))
    }
    
    private func createPresenter() throws -> (RecoveryPhraseCopyPhrasePresenter, TestDelegate) {
        let delegate = TestDelegate()
        let presenter = RecoveryPhraseCopyPhrasePresenter(recoveryPhrase: try testPhrase, delegate: delegate)
        
        return (presenter, delegate)
    }
    
    private var testPhrase: RecoveryPhrase {
        get throws {
            let testWords = [
                "clay", "vehicle", "crane", "debris", "usual", "canal",
                "puzzle", "concert", "asset", "render", "post", "cherry",
                "voyage", "original", "enrich", "gain", "basket", "dust",
                "version", "become", "desk", "oxygen", "doctor", "idea"
            ]
            
            return try RecoveryPhrase(phrase: testWords.joined(separator: " "))
        }
    }
}

private class TestDelegate: RecoveryPhraseCopyPhrasePresenterDelegate {
    var finishedPhrase: RecoveryPhrase?
    
    func finishedCopyingPhrase(with recoveryPhrase: RecoveryPhrase) {
        finishedPhrase = recoveryPhrase
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
