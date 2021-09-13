//
//  CopyPasteHelper.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 08/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit

struct CopyPasterHelper {
    static func copy(string: String) {
        UIPasteboard.general.string = string
    }
}
