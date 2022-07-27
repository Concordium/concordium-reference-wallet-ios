//
//  RecoveryPhrase.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 26/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct RecoveryPhrase: RandomAccessCollection, Equatable {
    struct InvalidRecoveryPhrase: Error {}
    
    fileprivate let words: [Substring]
    
    init(phrase: String) throws {
        let words = phrase.split(separator: " ")
        guard words.count == 24 else {
            throw InvalidRecoveryPhrase()
        }
        self.words = words
    }
    
    typealias Element = Substring
    typealias Iterator = RecoveryPhraseIterator
    typealias Index = RecoveryPhraseIndex
    typealias Indices = Range<RecoveryPhraseIndex>
    typealias SubSequence = Slice<RecoveryPhrase>
    
    var startIndex: RecoveryPhraseIndex {
        RecoveryPhraseIndex(index: 0)
    }
    
    var endIndex: RecoveryPhraseIndex {
        RecoveryPhraseIndex(index: 24)
    }
    
    var indices: Range<RecoveryPhraseIndex> {
        startIndex..<endIndex
    }
    
    func distance(from start: RecoveryPhraseIndex, to end: RecoveryPhraseIndex) -> Int {
        start.distance(to: end)
    }
    
    func formIndex(after i: inout RecoveryPhraseIndex) {
        i.index = Swift.min(24, i.index + 1)
    }
    
    func formIndex(before i: inout RecoveryPhraseIndex) {
        i.index = Swift.max(0, i.index - 1)
    }
    
    func index(after i: RecoveryPhraseIndex) -> RecoveryPhraseIndex {
        RecoveryPhraseIndex(index: Swift.min(24, i.index + 1))
    }
    
    func index(before i: RecoveryPhraseIndex) -> RecoveryPhraseIndex {
        RecoveryPhraseIndex(index: Swift.max(0, i.index - 1))
    }
    
    subscript(position: RecoveryPhraseIndex) -> Substring {
        words[position.index]
    }
    
    subscript(bounds: Range<RecoveryPhraseIndex>) -> Slice<RecoveryPhrase> {
       Slice(base: self, bounds: bounds)
    }
    
    func makeIterator() -> RecoveryPhraseIterator {
        RecoveryPhraseIterator(phrase: self)
    }
    
    func verify(words: [String]) -> Bool {
        for (index, word) in self.words.enumerated() {
            if words[index] != word {
                return false
            }
        }
        
        return true
    }
}

struct RecoveryPhraseIndex: Comparable, Strideable {
    typealias Stride = Int
    
    fileprivate var index: Int
    
    fileprivate init(index: Int) {
        self.index = index
    }
    
    func distance(to other: RecoveryPhraseIndex) -> Int {
        other.index - index
    }
    
    func advanced(by n: Int) -> RecoveryPhraseIndex {
        RecoveryPhraseIndex(index: min(24, index + n))
    }
    
    static func < (lhs: RecoveryPhraseIndex, rhs: RecoveryPhraseIndex) -> Bool {
        lhs.index < rhs.index
    }
}

struct RecoveryPhraseIterator: IteratorProtocol {
    typealias Element = Substring
    
    private let phrase: RecoveryPhrase
    private var index = 0
    
    fileprivate init(phrase: RecoveryPhrase) {
        self.phrase = phrase
    }
    
    mutating func next() -> Substring? {
        guard index < 24 else {
            return nil
        }
        
        let word = phrase.words[index]
        index += 1
        return word
    }
}
