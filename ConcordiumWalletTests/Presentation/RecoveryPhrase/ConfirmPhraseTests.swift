//
//  ConfirmPhraseTests.swift
//  ConcordiumWalletTests
//
//  Created by Niels Christian Friis Jakobsen on 27/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import XCTest
import Combine
@testable import Mock

class ConfirmPhraseTests: XCTestCase {
    func test_no_words_are_initially_selected() throws {
        let (presenter, _) = try createPresenter()
        
        XCTAssertEqual(presenter.viewModel.selectedWords, Array(repeating: "", count: 24))
    }
    
    func test_there_are_4_suggestions_for_each_word() throws {
        let (presenter, _) = try createPresenter()
        
        XCTAssertEqual(presenter.viewModel.suggestions.count, 24)
        
        let recoveryPhrase = try testPhrase
        
        for (index, suggestions) in presenter.viewModel.suggestions.enumerated() {
            let uniqueSuggestions = Set(suggestions)
            let word = String(recoveryPhrase[recoveryPhrase.startIndex.advanced(by: index)])
            XCTAssertEqual(uniqueSuggestions.count, 4)
            XCTAssert(uniqueSuggestions.contains(word))
        }
    }
    
    func test_selecting_a_word_updates_selected_words() throws {
        let (presenter, delegate) = try createPresenter()
        
        presenter.receive(event: .selectWord(index: 0, word: "clay"))
        presenter.receive(event: .selectWord(index: 5, word: "canal"))
        
        XCTAssertEqual(presenter.viewModel.selectedWords[0], "clay")
        XCTAssertEqual(presenter.viewModel.selectedWords[5], "canal")
        XCTAssertNil(presenter.viewModel.error)
        XCTAssertNil(delegate.confirmedPhrase)
    }
    
    func test_selecting_the_matching_words_confirms_the_phrase() throws {
        let (presenter, delegate) = try createPresenter()
        
        let phrase = try testPhrase
        
        for (index, word) in phrase.enumerated() {
            presenter.receive(event: .selectWord(index: index, word: String(word)))
        }
        
        XCTAssertEqual(delegate.confirmedPhrase, phrase)
    }
    
    func test_selecting_invalid_words_presents_an_error() throws {
        let (presenter, delegate) = try createPresenter()
        
        for index in 0..<24 {
            presenter.receive(event: .selectWord(index: index, word: "bogus"))
        }
        
        XCTAssertEqual(
            presenter.viewModel.error,
            "Incorrect secret recovery phrase. Please verify that each index has the right word."
        )
        XCTAssertNil(delegate.confirmedPhrase)
    }
    
    private func createPresenter() throws -> (RecoveryPhraseConfirmPhrasePresenter, TestDelegate) {
        let delegate = TestDelegate()
        let presenter = RecoveryPhraseConfirmPhrasePresenter(
            recoveryPhrase: try testPhrase,
            recoveryPhraseService: RecoveryServiceMock(),
            delegate: delegate
        )
        
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

private class TestDelegate: RecoveryPhraseConfirmPhrasePresenterDelegate {
    var confirmedPhrase: RecoveryPhrase?
    
    func recoveryPhraseHasBeenConfirmed(_ recoveryPhrase: RecoveryPhrase) {
        confirmedPhrase = recoveryPhrase
    }
}

private struct RecoveryServiceMock: RecoveryPhraseServiceProtocol {
    func recoverIdentities(for recoveryPhrase: RecoveryPhrase) -> AnyPublisher<[IdentityDataType], Error> {
        return .empty()
    }
}
