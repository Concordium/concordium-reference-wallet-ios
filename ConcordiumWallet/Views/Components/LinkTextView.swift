//
//  LinkTextView.swift
//  Mock
//
//  Created by Milan Sawicki on 16/11/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import UIKit

class LinkTextView: UITextView {

    // Provide the full text as a property
    var fullText: String = "" {
        didSet {
            updateAttributedText()
        }
    }

    // Define the tappable link
    private let linkText = "Concordium Wallet FAQ"
    private let linkURL = URL(string: "https://developer.concordium.software/en/mainnet/net/mobile-wallet-gen2/faq.html#wallet-migrate")!

    // MARK: - Initialization

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        // Enable tappable links
        isEditable = false
        isSelectable = true
        dataDetectorTypes = .link
    }

    // MARK: - Private Methods

    private func updateAttributedText() {
        guard !fullText.isEmpty else { return }

        let attributedString = NSMutableAttributedString(string: fullText)

        // Find the range of the text you want to make bold and tappable
        if let range = fullText.range(of: linkText) {
            let nsRange = NSRange(range, in: fullText)

            // Apply bold attribute
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: nsRange)

            // Apply tappable link
            attributedString.addAttribute(.link, value: linkURL, range: nsRange)
        }

        // Set the attributed text to the UITextView
        attributedText = attributedString
    }
}
