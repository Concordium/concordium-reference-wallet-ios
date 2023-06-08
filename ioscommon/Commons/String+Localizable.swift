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
        NSLocalizedString(self, comment: "")
    }
    
    var localizedNonempty: String? {
        let l = localized
        if l.isEmpty {
            return nil
        }
        return l
    }
}
