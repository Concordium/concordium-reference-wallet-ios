//
//  ConcordiumWalletTests.swift
//  ConcordiumWalletTests
//
//  Created by Concordium on 05/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import XCTest
@testable import ProdMainNet

class TransactionsCellViewModelTests: XCTestCase {
    
    //swiftlint:disable:next function_body_length
    func testTransactionCellFormat() {
        let amount = GTU(intValue: 1)
        let total = GTU(intValue: 1)
        let negativeTotal = GTU(intValue: -10)
        let cost = GTU(intValue: 1)
        let title = "998dfjac0gjalkjdkglikjc992kafbndfmnapop029ksl"
        
        var transaction1 = TransactionViewModel()
        transaction1.title = title
        transaction1.status = .received
        transaction1.amount = amount
        transaction1.total = total
        transaction1.cost = cost
        
        let cellVM = TransactionCellViewModel(transactionVM: transaction1)
        assert(cellVM.title == title)
        assert(cellVM.total == total.displayValueWithGStroke())
        assert(cellVM.showErrorIcon == false)
        assert(cellVM.costColor == .primary)
        assert(cellVM.showCostAsEstimate == true)
        
        var transaction2 = TransactionViewModel()
        transaction2.title = title
        transaction2.status = .committed
        transaction2.outcome = .ambiguous
        transaction2.amount = amount
        transaction2.total = total
        transaction2.cost = cost
        
        let cellVM2 = TransactionCellViewModel(transactionVM: transaction2)
        assert(cellVM.title == title)
        assert(cellVM.total == total.displayValueWithGStroke())
        assert(cellVM2.showErrorIcon == false)
        assert(cellVM2.costColor == .primary)
        assert(cellVM2.showCostAsEstimate == true)
        
        var transaction3 = TransactionViewModel()
        transaction3.title = title
        transaction3.status = .absent
        transaction3.amount = amount
        transaction3.total = total
        transaction3.cost = cost
        
        let cellVM3 = TransactionCellViewModel(transactionVM: transaction3)
        assert(cellVM3.title == title)
        assert(cellVM3.total == total.displayValueWithGStroke())
        assert(cellVM3.titleColor == .fadedText)
        assert(cellVM3.amountColor == .fadedText)
        assert(cellVM3.costColor == .fadedText)
        assert(cellVM3.showCostAsEstimate == true)
        assert(cellVM3.showStatusIcon == false)

        var transaction4 = TransactionViewModel()
        transaction4.title = title
        transaction4.status = .committed
        transaction4.outcome = .success
        transaction4.amount = amount
        transaction4.total = total
        transaction4.cost = cost
        
        let cellVM4 = TransactionCellViewModel(transactionVM: transaction4)
        assert(cellVM4.title == title)
        assert(cellVM4.total == total.displayValueWithGStroke())
        assert(cellVM4.showErrorIcon == false)
    
        var transaction5 = TransactionViewModel()
        transaction5.title = title
        transaction5.status = .finalized
        transaction5.outcome = .success
        transaction5.amount = amount
        transaction5.total = total
        transaction5.cost = cost
        
        let cellVM5 = TransactionCellViewModel(transactionVM: transaction5)
        assert(cellVM5.title == title)
        assert(cellVM5.total == total.displayValueWithGStroke())
        assert(cellVM5.showErrorIcon == false)
        assert(cellVM5.showCostAndAmount == false)
        assert(cellVM5.totalColor == .success)
        
        var transaction8 = TransactionViewModel()
        transaction8.title = title
        transaction8.status = .finalized
        transaction8.outcome = .success
        transaction8.total = negativeTotal
        transaction8.cost = cost
        
        let cellVM8 = TransactionCellViewModel(transactionVM: transaction8)
        assert(cellVM8.title == title)
        assert(cellVM8.total == negativeTotal.displayValueWithGStroke())
        assert(cellVM5.showErrorIcon == false)
        assert(cellVM8.showCostAndAmount == true)
        assert(cellVM8.totalColor == .text)
        
        var transaction6 = TransactionViewModel()
        transaction6.title = title
        transaction6.status = .committed
        transaction6.outcome = .reject
        transaction6.amount = amount
        transaction6.total = total
        transaction6.cost = cost
        
        let cellVM6 = TransactionCellViewModel(transactionVM: transaction6)
        assert(cellVM6.title == title)
        assert(cellVM6.total == total.displayValueWithGStroke())
        assert(cellVM6.titleColor == .fadedText)
        assert(cellVM6.amountColor == .fadedText)
        
        var transaction7 = TransactionViewModel()
        transaction7.title = title
        transaction7.status = .finalized
        transaction7.outcome = .reject
        transaction7.amount = amount
        transaction7.total = total
        transaction7.cost = cost
        
        let cellVM7 = TransactionCellViewModel(transactionVM: transaction7)
        assert(cellVM7.title == title)
        assert(cellVM7.total == total.displayValueWithGStroke())
        assert(cellVM7.titleColor == .fadedText)
        assert(cellVM7.amountColor == .fadedText)
    }
}
