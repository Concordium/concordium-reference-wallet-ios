//
//  ExportPrivateKeyView.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 15.12.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct ExportPrivateKeyView: Page {
    @ObservedObject var viewModel: ExportPrivateKeyViewModel
    
    var pageBody: some View {
        VStack {
            StyledLabel(text: viewModel.title, style: .body)
                .padding([.leading, .trailing], 20).padding([.bottom], 16)
            PrivateKeyContainer(viewModel: viewModel, state: viewModel.exportPrivateKey) {
                withAnimation {
                    self.viewModel.send(.showPrivateKey)
                }
            }
            Spacer()
            Button(viewModel.doneButtonTitle) {
                self.viewModel.send(.doneTapped)
            }
            .applyStandardButtonStyle()
        }
        .alert(item: $viewModel.alertText) { alertText in
            Alert(title: Text(""), message: Text(alertText.text), dismissButton: .default(Text("Ok")))
        }
        .padding([.leading, .trailing], 16)
        .padding([.bottom], 30)
        .padding([.top], 10)
    }
}

private struct PrivateKeyContainer: View {
    let viewModel: ExportPrivateKeyViewModel
    let state: ExportPrivateKeyState
    let tapAction: () -> Void
    
    var body: some View {
        ZStack {
            VStack {
                StyledLabel(text: state.shownTopMessage, style: .mono, color: Pallette.fadedText)
                    .padding([.leading, .trailing], 20).opacity(state.isPrivateKeyShown ? 1 : 0).fixedSize(horizontal: false, vertical: true)
                CopyKeyContainer(viewModel: viewModel, privateKey: state.privateKey) {
                        withAnimation {
                            self.viewModel.send(.copyTapped)
                        }
                }.padding([.leading, .trailing], 20).padding([.top, .bottom], 12).opacity(state.isPrivateKeyShown ? 1 : 0)
                Button(state.shownExportButtonTitle) {
                    viewModel.send(.exportTapped)
                }
                .applyStandardButtonStyle().opacity(state.isPrivateKeyShown ? 1 : 0)
            }.frame(maxWidth: .infinity).padding(20)
            VStack {
                StyledLabel(text: state.hiddenTopMessage, style: .mono, color: Pallette.fadedText)
                    .padding([.leading, .trailing], 16).padding([.bottom], 15.0)
                Image("reveal")
                StyledLabel(text: state.hiddenDownMessage, style: .mono, color: Pallette.fadedText)
                    .padding([.leading, .trailing], 16).padding([.top], 15)
            }.opacity(state.isPrivateKeyShown ? 0 : 1).padding(20.0)
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

private struct CopyKeyContainer: View {
    let viewModel: ExportPrivateKeyViewModel
    let privateKey: String
    let tapAction: () -> Void
    
    var body: some View {
        HStack {
            StyledLabel(text: privateKey, style: .body).fixedSize(horizontal: false, vertical: true)
            Image("Icon_Copy").padding([.leading, .trailing], 6)
        }.frame(maxWidth: .infinity).padding(12)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fillWithBorder(fill: Pallette.recoveryBackground, stroke: Pallette.primary)
            )
            .onTapGesture {
                tapAction()
            }
    }
}

private extension ExportPrivateKeyState {
    var isPrivateKeyShown: Bool {
        if case .shown = self {
            return true
        } else {
            return false
        }
    }
    
    var hiddenTopMessage: String {
        if case let .hidden(topMessage, _) = self {
            return topMessage
        } else {
            return ""
        }
    }
    
    var hiddenDownMessage: String {
        if case let .hidden(_, downMessage) = self {
            return downMessage
        } else {
            return ""
        }
    }
    
    var privateKey: String {
        if case let .shown(privateKey, _, _) = self {
            return privateKey
        } else {
            return ""
        }
    }
    
    var shownTopMessage: String {
        if case let .shown(_, topMessage, _) = self {
            return topMessage
        } else {
            return ""
        }
    }
    
    var shownExportButtonTitle: String {
        if case let .shown(_, _, exportButtonTitle) = self {
            return exportButtonTitle
        } else {
            return ""
        }
    }
}
