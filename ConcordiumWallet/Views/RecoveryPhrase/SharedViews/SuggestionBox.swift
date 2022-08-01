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
    let visibleSuggestions: Int
    let onSuggestionTapped: (String) -> Void
    
    init(
        suggestions: [String],
        selectedSuggestion: String?,
        minHeight: CGFloat = 40,
        visibleSuggestions: Int = 4,
        onSuggestionTapped: @escaping (String) -> Void
    ) {
        self.suggestions = suggestions
        self.selectedSuggestion = selectedSuggestion
        self.minHeight = minHeight
        self.visibleSuggestions = visibleSuggestions
        self.onSuggestionTapped = onSuggestionTapped
    }
    
    private var indexedSuggestions: [Indexed<String>] {
        if suggestions.count < visibleSuggestions {
            return (suggestions + Array(repeating: "", count: visibleSuggestions - suggestions.count))
                .indexed()
        } else {
            return suggestions[0..<visibleSuggestions].indexed()
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(indexedSuggestions) { suggestion in
                let isSelected = suggestion.value == selectedSuggestion
                
                StyledLabel(text: suggestion.value, style: .mono, color: isSelected ? Pallette.buttonText : Pallette.text)
                    .frame(maxWidth: .infinity, minHeight: minHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fillWithBorder(
                                fill: isSelected ? Pallette.primary : Color.clear, stroke: Pallette.primary
                            )
                    )
                    .opacity(suggestion.value.isEmpty ? 0 : 1)
                    .onTapGesture {
                        onSuggestionTapped(suggestion.value)
                    }
            }
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
