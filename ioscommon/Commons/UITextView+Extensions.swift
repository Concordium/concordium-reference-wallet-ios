//
//  UITextView+Extensions.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 22/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//
import Foundation
import UIKit
import Combine

extension UITextView {
    var textPublisher: AnyPublisher<String, Never> {
        weak var _self = self
        return NotificationCenter.default
            .publisher(for: UITextView.textDidChangeNotification, object: _self)
            .compactMap { $0.object as? UITextView }
            .map { $0.text ?? "" }
            .eraseToAnyPublisher()
    }
}
