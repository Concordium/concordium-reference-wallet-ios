//
//  SuggestionBox.swift
//  Mock
//
//  Created by Niels Christian Friis Jakobsen on 28/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct SuggestionBox: View {
    let suggestions: [String]
    let selectedSuggestion: String?
    let minHeight: CGFloat
    let onSuggestionTapped: (String) -> Void
    
    init(
        suggestions: [String],
        selectedSuggestion: String?,
        minHeight: CGFloat = 40,
        onSuggestionTapped: @escaping (String) -> Void
    ) {
        self.suggestions = suggestions
        self.selectedSuggestion = selectedSuggestion
        self.minHeight = minHeight
        self.onSuggestionTapped = onSuggestionTapped
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(suggestions, id: \.self) { suggestion in
                let isSelected = suggestion == selectedSuggestion
                
                StyledLabel(text: suggestion, style: .mono, color: isSelected ? Pallette.buttonText : Pallette.text)
                    .frame(maxWidth: .infinity, minHeight: minHeight)
                    .background(
                        SuggestionLabelBackground(
                            isSelected: isSelected
                        )
                    )
                    .onTapGesture {
                        onSuggestionTapped(suggestion)
                    }
            }
        }.frame(maxWidth: .infinity)
    }
}

private struct SuggestionLabelBackground: View {
    let isSelected: Bool
    
    var body: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 10)
                .fill(Pallette.primary)
        } else {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder()
                .foregroundColor(Pallette.primary)
        }
    }
}

struct SuggestionBox_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionBox(
            suggestions: ["First", "Second", "Third"],
            selectedSuggestion: nil
        ) { _ in }
        
        SuggestionBox(
            suggestions: ["First", "Second", "Third"],
            selectedSuggestion: "Second"
        ) { _ in }
    }
}
