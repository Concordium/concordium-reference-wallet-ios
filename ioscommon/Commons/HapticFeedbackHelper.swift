//
//  HapticFeedbackHelper.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 22/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit

struct HapticFeedbackHelper {
    enum FeedbackStyle {
        case light
        case medium
        case heavy
    }
    
    static func generate(feedback style: FeedbackStyle) {
        switch style {
        case .light:
            performLightHapticFeedback()
        case .medium:
            performMediumHapticFeedback()
        case .heavy:
            performHeavyHapticFeedback()
        }
    }
}

private extension HapticFeedbackHelper {
    static func performLightHapticFeedback() {
        let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        lightImpactFeedbackGenerator.prepare()
        lightImpactFeedbackGenerator.impactOccurred()
    }
    
    static func performMediumHapticFeedback() {
        let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        mediumImpactFeedbackGenerator.prepare()
        mediumImpactFeedbackGenerator.impactOccurred()
    }
    
    static func performHeavyHapticFeedback() {
        let heavyImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        heavyImpactFeedbackGenerator.prepare()
        heavyImpactFeedbackGenerator.impactOccurred()
    }
}
