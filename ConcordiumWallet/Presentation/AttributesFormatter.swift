//
//  AttributesFormatter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/13/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

enum DocumentType: String {
    case na = "0"
    case passport = "1"
    case nationalIDCard = "2"
    case drivingLicense = "3"
    case ImmigrationCard = "4"
}

enum Sex: String {
    case unknown = "0"
    case male = "1"
    case female = "2"
    case notApplicable = "9"
}

enum ChosenAttributeKeys: String, CodingKey, CaseIterable {
    case firstName, lastName, sex, dob, countryOfResidence, nationality
    case idDocType, idDocNo, idDocIssuer, idDocIssuedAt, idDocExpiresAt
    case nationalIdNo, taxIdNo
}

class AttributeFormatter {
    //swiftlint:disable cyclomatic_complexity
    static func format(key: ChosenAttributeKeys) -> String {
        var formattedKey = ""
        switch key {
            case .firstName:
                formattedKey = "attributes.firstName".localized
            case .countryOfResidence:
                formattedKey = "attributes.countryOfResidence".localized
            case .dob:
                formattedKey = "attributes.dob".localized
            case .idDocExpiresAt:
                formattedKey = "attributes.idDocExpiresAt".localized
            case .idDocIssuedAt:
                formattedKey = "attributes.idDocIssuedAt".localized
            case .idDocIssuer:
                formattedKey = "attributes.idDocIssuer".localized
            case .idDocNo:
                formattedKey = "attributes.idDocNo".localized
            case .idDocType:
                formattedKey = "attributes.idDocType".localized
            case .lastName:
                formattedKey = "attributes.lastName".localized
            case .nationalIdNo:
                formattedKey = "attributes.nationalIDNo".localized
            case .nationality:
                formattedKey = "attributes.nationality".localized
            case .sex:
                formattedKey = "attributes.sex".localized
            case .taxIdNo:
                formattedKey = "attributes.taxIDNo".localized
        }
        return formattedKey
    }
    
    static func format(value: String, for key: ChosenAttributeKeys) -> String {
        let internalFormatter = InternalFormatter()
        var formattedValue = ""
        switch key {
            case .firstName, .lastName:
                formattedValue = internalFormatter.format(name: value)
            case .idDocNo, .nationalIdNo, .taxIdNo :
                formattedValue = internalFormatter.format(plainNumber: value)
            case .dob:
                formattedValue = internalFormatter.format(dateOfBirth: value)
            case .idDocExpiresAt, .idDocIssuedAt:
                formattedValue = internalFormatter.format(date: value)
            case .idDocIssuer, .nationality, .countryOfResidence:
                formattedValue = internalFormatter.format(countryCode: value)
            case .idDocType:
                formattedValue = internalFormatter.format(documentType: value)
            case .sex:
                formattedValue = internalFormatter.format(sex: value)
        }
        return formattedValue
    }
}

private class InternalFormatter {
    func format(name: String) -> String {
        name
    }
    
    func format(plainNumber: String) -> String {
        plainNumber
    }
    
    func format(dateOfBirth: String) -> String {
        GeneralFormatter.formatISO8601Date(date: dateOfBirth, hasDay: true, outputFormat: "dd MMMM, yyyy")
    }
    
    func format(date: String) -> String {
        GeneralFormatter.formatISO8601Date(date: date, hasDay: true)
    }
    
    func format(countryCode: String) -> String {
        countryName(for: countryCode)
    }
    
    func format(sex: String) -> String {
        guard let sexEnum = Sex(rawValue: sex) else {
            return "sex.notKnown".localized
        }
        switch sexEnum {
            case .male:
                return "Male".localized
            case .female:
                return "Female".localized
            default:
                return "sex.notKnown".localized
        }
    }
    
    func format(documentType: String) -> String {
        guard let documentTypeEnum = DocumentType(rawValue: documentType) else {
            return ""
        }
        var formattedDocumentType = ""
        switch documentTypeEnum {
            case .na:
                formattedDocumentType = "Not applicable".localized
            case .drivingLicense:
                formattedDocumentType = "Driving License".localized
            case .ImmigrationCard:
                formattedDocumentType = "Immigration Card".localized
            case .nationalIDCard:
                formattedDocumentType = "National ID".localized
            case .passport:
                formattedDocumentType = "Passport".localized
        }
        return formattedDocumentType
    }
    
    func countryName(for countryCode: String) -> String {
        var countryName = ""
        //What locale should we use ??
        let locale = NSLocale.current
        let identifier = NSLocale(localeIdentifier: locale.identifier)
        countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: countryCode) ?? ""
        return countryName
    }
}
