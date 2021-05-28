//
//  String+Localizable.swift
//  Ohmatex
//
//  Created by Concordium on 1/15/20.
//  Copyright © 2020 Mjonler. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
