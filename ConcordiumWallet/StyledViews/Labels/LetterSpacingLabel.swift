//
// Created by Concordium on 09/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

class LetterSpacingLabel: BaseLabel {
    override func initialize() {
        addCharacterSpacing(kernValue: 2.3)
    }

    func addCharacterSpacing(kernValue: Double) {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
