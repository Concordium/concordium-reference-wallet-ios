//
// Created by Johan Rugager Vase on 21/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

struct GTU {
    static let conversionFactor: Int = 1000000
    static let maximumFractionDigits: Int = 6

    let intValue: Int

    init(displayValue: String) {
        if displayValue.count == 0 {
            intValue = 0
            return
        }
        let wholePart = displayValue.unsignedWholePart
        let fractionalPart = displayValue.fractionalPart(precision: GTU.maximumFractionDigits)
        let isNegative = displayValue.isNegative
        intValue = GTU.wholeAndFractionalValueToInt(wholeValue: wholePart, fractionalValue: fractionalPart, isNegative: isNegative)
    }

    init(intValue: Int) {
        self.intValue = intValue
    }

    init?(intValue: Int?) {
        guard let intValue = intValue else { return nil }
        self.intValue = intValue
    }

    func displayValueWithGStroke() -> String {
        let minimumFractionDigits = 2

        var str = GTU.intValueToUnsignedIntString(intValue,
                                                  minimumFractionDigits: minimumFractionDigits,
                                                  maxFractionDigits: GTU.maximumFractionDigits)
        
        // Unicode for "Latin Capital Letter G with Stroke" = U+01E4
        if intValue < 0 {
            str = "-Ǥ\(str)"
        } else {
            str = "Ǥ\(str)"
        }
        return str
    }

    func displayValue() -> String {
        let minimumFractionDigits = 2
        var stringValue = GTU.intValueToUnsignedIntString(intValue,
                                                          minimumFractionDigits: minimumFractionDigits,
                                                          maxFractionDigits: GTU.maximumFractionDigits)
        if intValue < 0 {
            stringValue = "-\(stringValue)"
        }
        return stringValue
    }

    private static func wholeAndFractionalValueToInt(wholeValue: Int, fractionalValue: Int, isNegative: Bool) -> Int {
        return (wholeValue * conversionFactor + fractionalValue) * (isNegative ? -1 : 1)
    }

    private static func intValueToUnsignedIntString(_ value: Int, minimumFractionDigits: Int, maxFractionDigits: Int) -> String {
        let absValue = abs(value)
        let wholeValueString = String(absValue / conversionFactor)
        var fractionVal = String(absValue % conversionFactor)
        
        //make it 6 digits
        let appendedZeros = String(conversionFactor).count - 1 - fractionVal.count
        if appendedZeros > 0 {
            for _ in 0..<appendedZeros {
                fractionVal = "0" + fractionVal
            }
        }
        
        //remove trailing zeros
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
