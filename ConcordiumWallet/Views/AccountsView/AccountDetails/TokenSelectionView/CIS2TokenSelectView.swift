//
//  TokenSelectionView.swift
//  ConcordiumWallet
//

import SDWebImageSwiftUI
import SwiftUI

struct CIS2TokenSelectView: View {
    @State var metadata: [CIS2TokenDetails]
    @State private var tokenIndex: String = ""
    var popView: (() -> Void)?
    var body: some View {
        VStack {
            Text("Please select the tokens you want to add from the contract.")
                .multilineTextAlignment(.center)
            TextField("Search for token ID", text: $tokenIndex)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .padding()
            ForEach(metadata, id: \.self) { metadata in
                HStack {
                    WebImage(url: metadata.thumbnail?.url)
                        .resizable()
                        .placeholder(Image(systemName: "photo"))
                        .indicator(.activity)
                        .transition(.fade(duration: 0.2))
                        .scaledToFit()
                        .frame(width: 45, height: 45, alignment: .center)

                    Text(metadata.name)
                    Spacer()
                    Toggle(isOn: .constant(false)) {}
                        .toggleStyle(CheckboxToggleStyle(style: .square))
                }.padding()
            }
            Spacer()
            HStack(spacing: 16) {
                Button(action: {}) {
                    Text("Back")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Pallette.primary)
                .cornerRadius(10)

                Button(action: { popView?() }) {
                    Text("Accept")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Pallette.primary)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct TokenSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CIS2TokenSelectView(metadata: [])
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    @SwiftUI.Environment(\.isEnabled) var isEnabled
    let style: Style // custom param

    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle() // toggle the state binding
        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.\(style.sfSymbolName).fill" : style.sfSymbolName)
                    .imageScale(.large)
                configuration.label
            }
        })
        .buttonStyle(PlainButtonStyle()) // remove any implicit styling from the button
        .disabled(!isEnabled)
    }

    enum Style {
        case square, circle

        var sfSymbolName: String {
            switch self {
            case .square:
                return "square"
            case .circle:
                return "circle"
            }
        }
    }
}
