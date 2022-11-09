//
//  CGFloat+Helper.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 1.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGFloat {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
