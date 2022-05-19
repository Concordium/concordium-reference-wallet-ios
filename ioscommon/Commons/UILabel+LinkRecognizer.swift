//
//  UILabel+LinkRegocnizer.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 19/05/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

class LinkPressedListener {
    private weak var label: UILabel?
    private let layoutManager = NSLayoutManager()
    private let textContainer = NSTextContainer(size: .zero)
    private let textStorage = NSTextStorage()
    
    fileprivate init(label: UILabel) {
        self.label = label
        textContainer.lineFragmentPadding = 0.0
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
    }
    
    @objc func handleTap(_ sender: UIGestureRecognizer) {
        guard let label = label, let attributedString = label.attributedText else {
            return
        }
        
        textContainer.size = label.bounds.size
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        textStorage.setAttributedString(attributedString)
        
        let touchLocation = sender.location(in: label)
        
        let indexOfCharacter = layoutManager.characterIndex(
            for: touchLocation,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        let link = attributedString.attribute(.link, at: indexOfCharacter, effectiveRange: nil) as? String
        
        if let link = link.flatMap(URL.init(string:)), UIApplication.shared.canOpenURL(link) {
            UIApplication.shared.open(link)
        }
    }
}

extension UILabel {
    func addOnLinkPressedListener() -> LinkPressedListener {
        let listener = LinkPressedListener(label: self)
        
        addGestureRecognizer(UITapGestureRecognizer(target: listener, action: #selector(listener.handleTap)))
        
        return listener
    }
}
