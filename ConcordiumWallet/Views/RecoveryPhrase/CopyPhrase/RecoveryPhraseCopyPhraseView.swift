//
//  RecoveryPhraseCopyPhraseView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct RecoveryPhraseCopyPhraseView: Page {
    @ObservedObject var viewModel: RecoveryPhraseCopyPhraseViewModel
    
    var pageBody: some View {
        VStack {
            PageIndicator(numberOfPages: 4, currentPage: 1)
            Text(verbatim: viewModel.title)
                .labelStyle(.body)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], 20)
            WordContainer(state: viewModel.recoveryPhrase) {
                withAnimation {
                    self.viewModel.send(.showPhrase)
                }
            }
            Spacer()
            ValidationBox(
                title: viewModel.copyValidationTitle,
                isChecked: viewModel.hasCopiedPhrase
            ) {
                self.viewModel.send(.confirmBoxTapped)
            }.padding([.leading, .trailing], 25)
            Spacer()
            Button(viewModel.buttonTitle) {
                self.viewModel.send(.continueTapped)
            }
            .applyStandardButtonStyle(disabled: !viewModel.hasCopiedPhrase)
        }
        .padding([.leading, .trailing], 16)
        .padding([.bottom], 30)
        .padding([.top], 10)
    }
}

private struct WordContainer: View {
    let state: RecoveryPhraseState
    let tapAction: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                VStack {
                    ForEach(0..<12) { index in
                        WordPill(index: index, word: state.word(for: index))
                            .ignoreAnimations()
                    }.opacity(state.areWordsShown ? 1 : 0)
                }.frame(maxWidth: .infinity)
                VStack {
                    ForEach(12..<24) { index in
                        WordPill(index: index, word: state.word(for: index))
                            .ignoreAnimations()
                    }.opacity(state.areWordsShown ? 1 : 0)
                }.frame(maxWidth: .infinity)
            }.padding(12)
            VStack {
                Image("reveal")
                Text(verbatim: state.hiddenMessage)
                    .multilineTextAlignment(.center)
            }.opacity(state.areWordsShown ? 0 : 1)
        }
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fillWithBorder(fill: Pallette.recoveryBackground, stroke: Pallette.fadedText)
        )
        .onTapGesture {
            tapAction()
        }
    }
}

private extension RecoveryPhraseState {
    var areWordsShown: Bool {
        if case .shown = self {
            return true
        } else {
            return false
        }
    }
    
    var hiddenMessage: String {
        if case let .hidden(message) = self {
            return message
        } else {
            return ""
        }
    }
    
    func word(for index: Int) -> String {
        if case let .shown(words) = self, words.count > index {
            return words[index]
        } else {
            return ""
        }
    }
}

private struct WordPill: View {
    let index: Int
    let word: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(verbatim: "\(index + 1).")
                .labelStyle(.mono)
                .foregroundColor(Pallette.recoveryPhraseText)
            Text(verbatim: word)
                .labelStyle(.mono)
                .foregroundColor(Pallette.recoveryPhraseText)
                .frame(maxWidth: .infinity)
        }.padding([.leading, .trailing], 12)
            .padding([.top, .bottom], 2)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder()
                    .foregroundColor(Pallette.primary)
            )
    }
}

private struct ValidationBox: View {
    let title: String
    let isChecked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(isChecked ? "checkmark_active" : "checkmark")
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text(verbatim: title)
                    .labelStyle(.body)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

struct RecoveryPhraseCopyPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseCopyPhraseView(
            viewModel: .init(
                title: "Please write all 24 words down in the right order.",
                recoveryPhrase: .hidden(message: "Tap to reveal your secret recovery phrase. Make sure noone else can see it."),
                copyValidationTitle: "I confirm I have written down my 24 word secret recovery phrase.",
                hasCopiedPhrase: false,
                buttonTitle: "Continue"
            )
        )
        
        RecoveryPhraseCopyPhraseView(
            viewModel: .init(
                title: "Please write all 24 words down in the right order.",
                recoveryPhrase: .shown(words: ["eerie", "anakin"]),
                copyValidationTitle: "I confirm I have written down my 24 word secret recovery phrase.",
                hasCopiedPhrase: true,
                buttonTitle: "Continue"
            )
        ).previewDevice(.init(rawValue: "iPhone SE (3rd generation)"))
    }
}
