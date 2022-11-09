//
//  Date+Helper.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 1.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

extension Date {
    
    // Returns a Date with the specified amount of components added to the one it is called with
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let components = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        
        return Calendar.current.date(byAdding: components, to: self)
    }
    
    // Returns a Date with the specified amount of components subtracted from the one it is called with
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
    }
    
    // Difference between two dates
    func offsetFrom(date: Date, withMinutesText minutesText: String = "Minutes", hoursText: String = "Hours", daysText: String = "Days") -> String {
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self)
        
        let minutes = "\(difference.minute ?? 0) \(minutesText)"
        let hours = "\(difference.hour ?? 0) \(hoursText)" + " " + minutes
        let days = "\(difference.day ?? 0) \(daysText)" + " " + hours
        
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        
        return ""
    }
    
    //
    func get(_ type: Calendar.Component) -> String {
        let t = Calendar.current.component(type, from: self)
        return (t < 10 ? "0\(t)" : t.description)
    }
    
    //
    static func localToUTC(dateStr: String, withFormat format: String = "yyyy-MM-dd hh:mm a") -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = format
        
            return dateFormatter.string(from: date)
        }
        return nil
    }

    static func utcToLocal(dateStr: String, withFormat format: String = "yyyy-MM-dd hh:mm a") -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = format
        
            return dateFormatter.string(from: date)
        }
        return nil
    }
}
