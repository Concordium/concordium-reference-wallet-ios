//
// Created by Concordium on 21/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import BigInt
struct GTU: Codable {
    private let conversionFactor: Int = 1000000
    private let maximumFractionDigits: Int
    
    /// Useful for comparing against 0
    static let zero: GTU = GTU(intValue: 0)
    static let max: GTU = GTU(intValue: .max)

    private(set) var intValue: Int

    init(displayValue: String, maximumFractionDigits: Int = 6) {
        self.maximumFractionDigits = maximumFractionDigits

        if displayValue.count == 0 {
            intValue = 0
            return
        }
        let wholePart = displayValue.unsignedWholePart
        let fractionalPart = displayValue.fractionalPart(precision: maximumFractionDigits)
        let isNegative = displayValue.isNegative
        intValue = GTU.wholeAndFractionalValueToInt(wholeValue: wholePart, fractionalValue: fractionalPart, isNegative: isNegative, conversionFactor: conversionFactor)
    }

    init(intValue: Int, maximumFractionDigits: Int = 6) {
        self.intValue = intValue
        self.maximumFractionDigits = maximumFractionDigits
    }

    init?(intValue: Int?, maximumFractionDigits: Int = 6) {
        guard let intValue = intValue else { return nil }
        self.intValue = intValue
        self.maximumFractionDigits = maximumFractionDigits
    }
    
    // GTU is encoded as a string containing the int value
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let stringValue = try container.decode(String.self)
        
        guard let intValue = Int(stringValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "\(stringValue) is not a valid GTU amount")
        }
        
        self.init(intValue: intValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(String(intValue))
    }

    func displayValueWithGStroke() -> String {
        let minimumFractionDigits = 2

        var str = intValueToUnsignedIntString(intValue,
                                                  minimumFractionDigits: minimumFractionDigits,
                                                  maxFractionDigits: maximumFractionDigits)
        
        // Unicode for "Latin Capital Letter G with Stroke" = U+01E4
        if intValue < 0 {
            str = "-Ͼ\(str)"
        } else {
            str = "Ͼ\(str)"
        }
        return str
    }

    func displayValue() -> String {
        let minimumFractionDigits = 2
        var stringValue = intValueToUnsignedIntString(intValue,
                                                          minimumFractionDigits: minimumFractionDigits,
                                                          maxFractionDigits: maximumFractionDigits)
        if intValue < 0 {
            stringValue = "-\(stringValue)"
        }
        return stringValue
    }
    
    static func isValid(displayValue: String) -> Bool {        
        return displayValue.unsignedWholePart <= (Int.max - 999999)/1000000 && displayValue.matches(regex: "^[0-9]*[\\.,]?[0-9]{0,6}$")
    }

    private static func wholeAndFractionalValueToInt(wholeValue: Int, fractionalValue: Int, isNegative: Bool, conversionFactor: Int) -> Int {
        return (wholeValue * conversionFactor + fractionalValue) * (isNegative ? -1 : 1)
    }

    private func intValueToUnsignedIntString(_ value: Int, minimumFractionDigits: Int, maxFractionDigits: Int) -> String {
        let absValue = abs(value)
        let wholeValueString = String(absValue / conversionFactor)
        var fractionVal = String(absValue % conversionFactor)
        
        // make it 6 digits
        let appendedZeros = String(conversionFactor).count - 1 - fractionVal.count
        if appendedZeros > 0 {
            for _ in 0..<appendedZeros {
                fractionVal = "0" + fractionVal
            }
        }
        
        // remove trailing zeros
        let length = min(fractionVal.count, maximumFractionDigits)
        var removed = false
        for i in stride(from: 0, to: -length + minimumFractionDigits, by: -1) {
            if fractionVal[fractionVal.index(fractionVal.endIndex, offsetBy: i - 1)] != "0" {
                fractionVal = String(fractionVal[..<fractionVal.index(fractionVal.endIndex, offsetBy: i)])
                removed = true
                break
            }
        }
        if !removed {
            fractionVal = String(fractionVal[..<fractionVal.index(fractionVal.endIndex, offsetBy: -length + minimumFractionDigits)])
        }
        let decimalSeparator = NumberFormatter().decimalSeparator!
        return wholeValueString + decimalSeparator + fractionVal
    }
}

extension GTU: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(intValue)
    }

    public static func == (lhs: GTU, rhs: GTU) -> Bool {
        lhs.intValue == rhs.intValue
    }
}

extension GTU: Comparable {
    static func < (lhs: GTU, rhs: GTU) -> Bool {
        lhs.intValue < rhs.intValue
    }
}

extension GTU: Numeric {
    var magnitude: UInt {
        intValue.magnitude
    }
    
    init?<T>(exactly source: T) where T: BinaryInteger {
        self.init(intValue: Int(exactly: source))
    }
    
    init(integerLiteral value: IntegerLiteralType) {
        self.init(intValue: value)
    }
    
    static func + (lhs: GTU, rhs: GTU) -> GTU {
        return GTU(intValue: lhs.intValue + rhs.intValue)
    }
    
    static func * (lhs: GTU, rhs: GTU) -> GTU {
        return GTU(intValue: lhs.intValue * rhs.intValue)
    }
    
    static func *= (lhs: inout GTU, rhs: GTU) {
        lhs.intValue *= rhs.intValue
    }
    
    static func - (lhs: GTU, rhs: GTU) -> GTU {
        return GTU(intValue: lhs.intValue - rhs.intValue)
    }
}
