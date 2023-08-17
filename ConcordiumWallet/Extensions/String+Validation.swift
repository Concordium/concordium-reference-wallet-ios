//
//  String+Validation.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 4.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

extension String {
    
    // MARK: - Public
    
    var isEmpty: Bool {
        if self.count == 0 {
            return true
        }
        
        return false
    }
    
    var isEmailInvalid: Bool {
        let regularExpressionPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        do {
            let regularExpression = try NSRegularExpression(pattern: regularExpressionPattern, options: .caseInsensitive)
            let regularExpressionMatches = regularExpression.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.count))
            
            if regularExpressionMatches == 0 {
                return true
            }
        }
        catch {
            print("Regular expression error.")
        }
        
        return false
    }
    
    var isNumeric: Bool {
        allSatisfy { "0" <= $0 && $0 <= "9" }
     }
}
