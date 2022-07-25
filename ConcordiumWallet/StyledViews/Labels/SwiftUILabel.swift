//
//  SwiftUILabel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

enum LabelStyle {
    case title
    case body
    case mono
    
    fileprivate func font(weight: Font.Weight?) -> Font {
        let defaultFont: Font = {
            switch self {
            case .title:
                return Font(Fonts.title)
            case .body:
                return Font(Fonts.body)
            case .mono:
                return Font(Fonts.mono ?? Fonts.body)
            }
        }()
        
        if let weight = weight {
            return defaultFont.weight(weight)
        } else {
            return defaultFont
        }
    }
    
    fileprivate var color: Color {
        switch self {
        case .title:
            return Color("primary")
        case .body:
            return Color("text")
        case .mono:
            return Color("text")
        }
    }
}

extension View {
    func labelStyle(_ style: LabelStyle, weight: Font.Weight? = nil) -> some View {
        return self
            .font(style.font(weight: weight))
            .foregroundColor(style.color)
    }
}
