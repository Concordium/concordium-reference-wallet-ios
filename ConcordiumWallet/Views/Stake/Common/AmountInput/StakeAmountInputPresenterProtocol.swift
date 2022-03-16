//
//  StakeAmountInputPresenterProtocol.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 03/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum StakeError: Error {
    case minimumAmount(GTU)
    case maximumAmount(GTU)
    case notEnoughFund(GTU)
    case poolLimitReached(GTU, GTU)
    case internalError
    
    var localizedDescription: String {
        switch self {
        case .minimumAmount(let min):
            return String(format: "stake.inputAmount.error.minAmount".localized, min.displayValueWithGStroke())
        case .maximumAmount(let max):
            return String(format: "stake.inputAmount.error.maxAmount".localized, max.displayValueWithGStroke())
        case .notEnoughFund(_):
            return "stake.inputAmount.error.funds".localized
        case .poolLimitReached(_, _):
            return "stake.inputAmount.error.poolLimit".localized
        case .internalError:
            return ""
        }
    }
}

struct BalanceViewModel {
    var label: String
    var value: String
}

class StakeAmountInputViewModel {
    @Published var title: String = ""
    
    @Published var firstBalance: BalanceViewModel = BalanceViewModel(label: "", value: "")
    @Published var secondBalance: BalanceViewModel = BalanceViewModel(label: "", value: "")

    @Published var amountMessage: String = ""
    @Published var amount: String = ""
    @Published var isAmountLocked: Bool = false
    @Published var amountErrorMessage: String? = nil
    @Published var transactionFee: String? = ""
    
    @Published var showsPoolLimits: Bool = false
    @Published var currentPoolLimit: BalanceViewModel? = BalanceViewModel(label: "", value: "")
    @Published var poolLimit: BalanceViewModel? = BalanceViewModel(label: "", value: "")
    
    @Published var isRestakeSelected: Bool = true
    
    @Published var bottomMessage: String = ""
    @Published var isAmountValid: Bool = false
}

// MARK: -
// MARK: Presenter
protocol StakeAmountInputPresenterProtocol: AnyObject {
	var view: StakeAmountInputViewProtocol? { get set }
    func viewDidLoad()
    func pressedContinue()
}
