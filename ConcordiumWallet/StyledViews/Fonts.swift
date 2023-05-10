//
//  Fonts.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

/// Legacy font faces.
struct Fonts {
    static let title = UIFont.systemFont(ofSize: 32)
    static let heading = UIFont.systemFont(ofSize: 24)
    static let subheading = UIFont.systemFont(ofSize: 20)
    static let body = UIFont.systemFont(ofSize: 15)
    static let navigationBarTitle = UIFont.systemFont(ofSize: 17, weight: .bold)
    static let info = UIFont.systemFont(ofSize: 16, weight: .bold)
    static let buttonTitle = UIFont.systemFont(ofSize: 17, weight: .regular)
    static let cellHeading = UIFont.systemFont(ofSize: 10, weight: .medium)
    static let tabBar = UIFont.systemFont(ofSize: 14, weight: .medium)
    static let mono = UIFont(name: "RobotoMono-Regular", size: 12)
}

extension UIFont {
    /// Enum that represent typeface styles of `WorkSans`.
    public enum WorkSansType: String {
        case semibold = "Roman-SemiBold"
        case regular = "-Regular"
        case light = "Roman-Light"
        case bold = "Roman-Bold"
    }

    /// Main font used in the app named `WorkSans`.
    /// - Parameters:
    ///     - size: size of the font.
    ///     - type: constants that represent standard typeface styles. Default value is `regular`.
    static func WorkSans(size: CGFloat = UIFont.systemFontSize, _ type: WorkSansType = .regular) -> UIFont {
        return UIFont(name: "WorkSans\(type.rawValue)", size: size)!
    }
}
