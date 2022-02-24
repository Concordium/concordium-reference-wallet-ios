//
//  UIButton+Extensions.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 24/02/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit
import Combine

extension UIButton {
    var tapPublisher: EventPublisher {
        publisher(for: .touchUpInside)
    }
}
