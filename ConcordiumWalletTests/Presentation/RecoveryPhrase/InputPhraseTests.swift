//
//  InputPhraseTests.swift
//  ConcordiumWalletTests
//
//  Created by Niels Christian Friis Jakobsen on 01/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import XCTest
import Combine
@testable import Mock

@MainActor
class InputPhraseTests: ConcordiumTestCase {
    func test_no_words_are_initially_selected() {
        let (presenter, _) = createPresenter()
        
        XCTAssert(presenter.viewModel.selectedWords.allSatisfy({ $0.isEmpty }))
        XCTAssertEqual(presenter.viewModel.selectedWords.count, 24)
        XCTAssert(presenter.viewModel.currentSuggestions.isEmpty)
        XCTAssertEqual(presenter.viewModel.currentInput, "")
        XCTAssertNil(presenter.viewModel.error)
    }
    
    func test_suggestions_are_shown_after_entering_3_characters() {
        let (presenter, _) = createPresenter()
        
        presenter.viewModel.currentInput = "v"
        XCTAssert(presenter.viewModel.currentSuggestions.isEmpty)
        presenter.viewModel.currentInput = "ve"
        XCTAssert(presenter.viewModel.currentSuggestions.isEmpty)
        presenter.viewModel.currentInput = "ver"
        XCTAssertEqual(
            presenter.viewModel.currentSuggestions,
            ["verb", "verify", "version", "very"]
        )
        presenter.viewModel.currentInput = "ve"
        XCTAssert(presenter.viewModel.currentSuggestions.isEmpty)
    }
    
    func test_selected_words_are_shown() {
        let (presenter, _) = createPresenter()
        
        presenter.receive(event: .wordSelected(index: 0, word: "silly"))
        presenter.receive(event: .wordSelected(index: 4, word: "raven"))
        
        XCTAssertEqual(
            presenter.viewModel.selectedWords,
            ["silly", "", "", "", "raven"] + Array(repeating: "", count: 19)
        )
    }
    
    func test_clear_all_clears_all_selected_words() {
        let (presenter, _) = createPresenter()
        
        presenter.receive(event: .wordSelected(index: 0, word: "silly"))
        presenter.receive(event: .wordSelected(index: 3, word: "liar"))
        presenter.receive(event: .clearAll)
        
        XCTAssertEqual(presenter.viewModel.selectedWords, Array(repeating: "", count: 24))
    }
    
    func test_clear_below_clears_all_below_an_index() {
        let (presenter, _) = createPresenter()
        
        presenter.receive(event: .wordSelected(index: 0, word: "silly"))
        presenter.receive(event: .wordSelected(index: 1, word: "raven"))
        presenter.receive(event: .wordSelected(index: 2, word: "liar"))
        presenter.receive(event: .wordSelected(index: 3, word: "reduce"))
        presenter.receive(event: .clearBelow(index: 1))
        
        XCTAssertEqual(
            presenter.viewModel.selectedWords,
            ["silly", "raven"] + Array(repeating: "", count: 22)
        )
    }
    
    func test_entering_an_invalid_phrase_shows_an_error() {
        let (presenter, delegate) = createPresenter()
        
        for index in 0..<24 {
            presenter.receive(event: .wordSelected(index: index, word: "bogus"))
        }
        
        XCTAssertNotNil(presenter.viewModel.error)
        XCTAssertNil(delegate.receivedPhrase)
    }
    
    func test_entering_a_valid_phrase_completes_input() throws {
        let (presenter, delegate) = createPresenter()
        let phrase = try validPhrase
        
        for (index, word) in phrase.enumerated() {
            presenter.receive(event: .wordSelected(index: index, word: String(word)))
        }
        
        XCTAssertNil(presenter.viewModel.error)
        XCTAssertEqual(phrase, delegate.receivedPhrase)
    }
    
    private func createPresenter() -> (RecoveryPhraseInputPresenter, TestDelegate) {
        let delegate = TestDelegate()
        let dependencyProvider = getTestProvider()
        let presenter = RecoveryPhraseInputPresenter(
            recoveryService: dependencyProvider.recoveryPhraseService(),
            delegate: delegate
        )
        
        return (presenter, delegate)
    }
 
    private var validPhrase: RecoveryPhrase {
        get throws {
            let words = [
                "silly", "raven", "liar", "reduce",
                "mule", "walnut", "victory", "glass",
                "current", "collect", "unveil", "crystal",
                "warfare", "flock", "valve", "bottom",
                "lend", "ethics", "sausage", "spread",
                "regret", "ten", "wood", "protect"
            ]
            
            return try RecoveryPhrase(phrase: words.joined(separator: " "))
        }
    }
}

private class TestDelegate: RecoveryPhraseInputPresenterDelegate {
    private(set) var receivedPhrase: RecoveryPhrase?
    
    func phraseInputReceived(validPhrase: RecoveryPhrase) {
        self.receivedPhrase = validPhrase
    }
}
