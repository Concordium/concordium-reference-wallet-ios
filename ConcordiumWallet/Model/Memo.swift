//
//  Memo.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 22/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

protocol MemoDataType {
    var memo: String { get set }
    var size: Int { get }
    var isSizeValid: Bool { get }
}

class Memo: MemoDataType {
    var memo: String
    
    var size: Int { memo.utf8.count }
    
    var isSizeValid: Bool { size <= 256 }
    
    init(memo: String) {
        self.memo = memo
    }
}
