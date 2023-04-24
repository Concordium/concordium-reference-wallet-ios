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
    case heading
    case subheading
    case body
    case mono
    
    fileprivate func font(weight: Font.Weight?) -> Font {
        let defaultFont: Font = {
            switch self {
            case .title:
                return Font(Fonts.title)
            case .heading:
                return Font(Fonts.heading)
            case .subheading:
                return Font(Fonts.subheading)
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
            return Pallette.primary
        case .heading:
            return Pallette.text
        case .subheading:
            return Pallette.text
        case .body:
            return Pallette.text
        case .mono:
            return Pallette.text
        }
    }
}

extension View {
    func labelStyle(
        _ style: LabelStyle,
        weight: Font.Weight? = nil,
        color: Color? = nil
    ) -> some View {
        return self
            .font(style.font(weight: weight))
            .foregroundColor(color ?? style.color)
    }
}

struct StyledLabel: View {
    let text: String
    let style: LabelStyle
    let weight: Font.Weight?
    let color: Color?
    let textAlignment: TextAlignment
    
    init(
        text: String,
        style: LabelStyle,
        weight: Font.Weight? = nil,
        color: Color? = nil,
        textAlignment: TextAlignment = .center
    ) {
        self.text = text
        self.style = style
        self.weight = weight
        self.color = color
        self.textAlignment = textAlignment
    }
    
    var body: some View {
        Text(verbatim: text)
            .labelStyle(style, weight: weight, color: color)
            .multilineTextAlignment(textAlignment)
    }
}

struct ErrorLabel: View {
    let error: String?
    
    var body: some View {
        if let error = error {
            StyledLabel(text: error, style: .body, color: Pallette.error)
        } else {
            EmptyView()
        }
    }
}
