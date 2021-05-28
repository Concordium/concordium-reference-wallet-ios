//
//  GeneralFormatter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/13/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

class GeneralFormatter {
    //output Format : if not specified, default is "MMMM, yyyy"
    static func formatISO8601Date(date: String, hasDay: Bool = false, outputFormat: String = "MMMM, yyyy") -> String {
        let formatter = DateFormatter()
        if hasDay {
            formatter.dateFormat = "yyyyMMdd"
        } else {
            formatter.dateFormat = "yyyyMM"
        }
        let convertedDate = formatter.date(from: date)
        guard convertedDate != nil else {
            //If string cannot be interpreted as date, just return the string
            return date
        }
        let resultDateFormatter = DateFormatter()

        resultDateFormatter.dateFormat = outputFormat
        return resultDateFormatter.string(from: convertedDate!)
    }
    
    static func formatTime(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static func formatDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    static func formatDateWithTime(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
