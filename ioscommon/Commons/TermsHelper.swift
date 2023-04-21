//
//  TermsHelper.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 24/11/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import UIKit

struct TermsHelper {
    // swiftlint:disable function_body_length
    static func createTermsAttributedString(titleAttribute: [NSAttributedString.Key: Any],
                                            detailsAttribute: [NSAttributedString.Key: Any],
                                            subtitleAttribute: [NSAttributedString.Key: Any],
                                            paragraphAttribute: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms1.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms2.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms3.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms4.subtitle".localized, attributes: subtitleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms5.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms6.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms7a.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms7.paragraph1".localized, attributes: paragraphAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms7.paragraph2".localized, attributes: paragraphAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms7b.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms8.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms9.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms10.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms11.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms12.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms13.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms14.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms15.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms16.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms17.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms18.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms19.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms20.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms21.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms22.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms23.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms24.subtitle".localized, attributes: subtitleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms25.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms26.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms27a.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms27.paragraph1".localized, attributes: paragraphAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms27.paragraph2".localized, attributes: paragraphAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms27.paragraph3".localized, attributes: paragraphAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms27b.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms28.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms29.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms30.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms31.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms32.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms33.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms34.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms35.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms36.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms37.details".localized, attributes: detailsAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms38.title".localized, attributes: titleAttribute))
        text.append(NSAttributedString(string: "termsAndConditionsScreen.terms39.details".localized, attributes: detailsAttribute))
        
        return text
    }
    
    static var currentTerms: String = {
        TermsHelper.createTermsAttributedString(titleAttribute: [:],
                                                detailsAttribute: [:],
                                                subtitleAttribute: [:],
                                                paragraphAttribute: [:])
            .string
    }()
}
