//
//  UITextField+Extensions.swift
//  ConcordiumWallet
//
//  Created by Mohamed Ghonemi on 3/16/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit
import Combine

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        weak var _self = self
        return NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: _self)
            .compactMap { $0.object as? UITextField }
            .map { $0.text ?? "" }
            .eraseToAnyPublisher()
    }
}
