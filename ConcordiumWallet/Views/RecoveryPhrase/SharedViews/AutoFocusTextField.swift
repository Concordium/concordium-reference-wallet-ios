//
//  AutoFocusTextField.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct AutoFocusTextField: View {
    @Binding var text: String
    @State private var focused = false
    
    var body: some View {
        TextFieldWrapper(text: $text, focused: $focused)
            .frame(maxWidth: .infinity)
            .onAppear {
                focused = true
            }
            .onDisappear {
                focused = false
            }
    }
}

private struct TextFieldWrapper: UIViewRepresentable {
    @Binding var text: String
    @Binding var focused: Bool
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TextFieldWrapper
        
        init(parent: TextFieldWrapper) {
            self.parent = parent
        }
        
        @objc
        func textChanged(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        
        textField.delegate = context.coordinator
        textField.text = text
        textField.font = Fonts.mono
        textField.textColor = .text
        textField.textAlignment = .center
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .alphabet
        textField.autocapitalizationType = .none
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged), for: .editingChanged)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        let focusChanged = focused != context.coordinator.parent.focused
        context.coordinator.parent = self
        if focusChanged {
            if focused {
                uiView.becomeFirstResponder()
            } else {
                uiView.resignFirstResponder()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

struct AutoFocusTextField_Previews: PreviewProvider {
    static var previews: some View {
        AutoFocusTextField(text: .constant(""))
    }
}
