//
//  DateFormatter+Helper.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 3.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

extension DateFormatter {
    class func string(from date: Date, withFormat format: String = "EEEE, dd MMMM, yyyy") -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
    }
    
    class func stringWithoutConvertingToTimeZone(from date: Date, withFormat format: String = "EEEE, dd MMMM, yyyy") -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
    }
    
    class func date(from string: String, withFormat format: String = "EEEE, dd MMMM, yyyy") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        guard let date = dateFormatter.date(from: string) else {
          preconditionFailure("Take a look to your format")
        }
        
        return date
    }
    
    class func dateWithoutConvertingToTimeZone(from string: String, withFormat format: String = "EEEE, dd MMMM, yyyy") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = format
        
        guard let date = dateFormatter.date(from: string) else {
          preconditionFailure("Take a look to your format")
        }
        
        return date
    }
}
