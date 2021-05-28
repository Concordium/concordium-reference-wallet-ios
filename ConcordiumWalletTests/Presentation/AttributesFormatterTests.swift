//
//  AttributesFormatterTests.swift
//  ConcordiumWalletTests
//
//  Created by Concordium on 01/07/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import XCTest
@testable import ProdMainNet

class AttributesFormatterTests : XCTestCase {
    func testFormatCountry() {
        //Arrange
        let countryTestData = [("DK", "Denmark"), ("DE", "Germany"), ("EG", "Egypt"), ("JPN", "Japan")]
        
        for country in  countryTestData {
            //Act
            let countryName = AttributeFormatter.format(value: country.0, for: .countryOfResidence)
        
            //Assert
            assert(countryName == country.1)
        }
    }
    
    func testFormatDate() {
        //Arrange
        let dateInput = "20200401"
        
        //Act
        let formattedDate = AttributeFormatter.format(value: dateInput, for: .idDocIssuedAt)
        
        //Assert
        assert(formattedDate == "April, 2020")
    }
    
    func testFormatSex() {
        //Test 1
        //Arrange
        let male = "1"
        
        //Act
        var formattedSex = AttributeFormatter.format(value: male, for: .sex)
        
        //Assert
        assert(formattedSex == "Male".localized)
        
        //Test 2
        //Arrange
        let female = "2"
        
        //Act
        formattedSex = AttributeFormatter.format(value: female, for: .sex)
        
        //Assert
        assert(formattedSex == "Female".localized)
        
        //Test 3
        //Arrange
        let notKnown = "4"
        
        //Act
        formattedSex = AttributeFormatter.format(value: notKnown, for: .sex)
        
        //Assert
        assert(formattedSex == "sex.notKnown".localized)
    }
    
    func testFormatDocumentType() {
        //Concordium specification:
        //na=0, passport=1, national id card=2, driving license=3, immigration card=4
        
        //Arrange
        let values = [("0", "Not applicable".localized),
                      ("1", "Passport".localized),
                      ("2", "National ID".localized),
                      ("3", "Driving License".localized),
                      ("4", "Immigration Card".localized)
                     ]
        
        for value in values {
            //Act
            let formattedDocumentType = AttributeFormatter.format(value: value.0, for: .idDocType)
            //Assert
            assert(formattedDocumentType == value.1)
        }
    }
}
