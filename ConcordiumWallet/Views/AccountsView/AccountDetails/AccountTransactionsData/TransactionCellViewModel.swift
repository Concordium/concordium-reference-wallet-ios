//
//  TransactionCellViewModel.swift
//  ConcordiumWallet
//
//  Created by Concordium on 5/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

struct TransactionCellViewModel {
    var title = ""
    var date = ""
    var memo: String?
    var fullDate = ""
    var total = ""
    var amount = ""
    var cost = ""
    var titleColor: UIColor = .text
    var totalColor: UIColor = .text
    var amountColor: UIColor = .text
    var costColor: UIColor = .text
    var showLock = false
    var showCostAndAmount = true
    var showErrorIcon = true
    var showStatusIcon = true
    var statusIcon = #imageLiteral(resourceName: "ok_x2")
    var showCostAsEstimate = false

    // swiftlint:disable all
    init(transactionVM: TransactionViewModel) {
        title = transactionVM.title
        date = GeneralFormatter.formatTime(for: transactionVM.date)
        memo = transactionVM.memo?.displayValue ?? ""
        fullDate = GeneralFormatter.formatDateWithTime(for: transactionVM.date)
        total = transactionVM.total?.displayValueWithGStroke() ?? ""
        showLock = transactionVM.total?.displayValueWithGStroke() == nil
        
        if transactionVM.status == .received
                   || (transactionVM.status == .committed && transactionVM.outcome == .ambiguous) {
            showErrorIcon = false
            statusIcon = #imageLiteral(resourceName: "time")
            costColor = .primary
            showCostAsEstimate = true
        } else if transactionVM.status == .absent {
            titleColor = .fadedText
            amountColor = .fadedText
            costColor = .fadedText
            showCostAsEstimate = true
            showStatusIcon = false
        } else if transactionVM.status == .committed && transactionVM.outcome == .success {
            showErrorIcon = false
            statusIcon = #imageLiteral(resourceName: "ok")
            if let total = transactionVM.total?.intValue, total > 0 {
                totalColor = .success
            }
        } else if transactionVM.status == .finalized && transactionVM.outcome == .success {
            showErrorIcon = false
            if let total = transactionVM.total?.intValue, total > 0 {
                totalColor = .success
            }
        } else if transactionVM.status == .committed && transactionVM.outcome == .reject {
            titleColor = .fadedText
            statusIcon = #imageLiteral(resourceName: "ok")
            amountColor = .fadedText
        } else if transactionVM.status == .finalized && transactionVM.outcome == .reject {
            titleColor = .fadedText
            amountColor = .fadedText
        }
        
        if transactionVM.showCostAsShieleded {
            self.cost = "transactions.shieledtransactionfee".localized
            self.amount = ""
        } else {
            if let cost = transactionVM.cost?.displayValueWithGStroke(),
                let amount = transactionVM.amount?.displayValueWithGStroke() {
                self.amount = amount
                self.cost = " - " + cost + " Fee"

                // Prepend with ~ if cost is estimated.
                if showCostAsEstimate {
                    self.cost = self.cost.replacingOccurrences(of: "- ", with: "- ~", options: NSString.CompareOptions.literal, range: nil)
                }
            }
        }
    }
}
