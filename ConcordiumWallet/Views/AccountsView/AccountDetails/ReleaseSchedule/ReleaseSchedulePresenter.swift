//
//  ReleaseSchedulePresenter.swift
//  ConcordiumWallet
//
//  Concordium on 27/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

class ReleaseScheduleListViewModel {
    @Published var releaseScheduleList = [ReleaseScheduleViewModel]()
    @Published var total: GTU?
    @Published var title: String = ""
    
    init(releaseSchedule: ReleaseScheduleDataType, account: AccountDataType) {
        self.title = account.displayName + " " + "releaseschedule.title".localized
        self.total = GTU(intValue: releaseSchedule.total)
        self.releaseScheduleList = []
        for schedule in releaseSchedule.schedule {
            let amount = Int(schedule.amount ?? "0") ?? 0
            let date = Date(timeIntervalSince1970: Double(schedule.timestamp)/1000) // we get the timestamp in ms
            let viewModel = ReleaseScheduleViewModel(amount: GTU(intValue: amount), date: date, transactionIds: schedule.transactions)
            self.releaseScheduleList.append(viewModel)
        }
    }
    init() {
    }
}

struct ReleaseScheduleHeader: Hashable {
    var date: Date
    var amount: GTU
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(amount)
    }
    
    static func == (lhs: ReleaseScheduleHeader, rhs: ReleaseScheduleHeader) -> Bool {
        lhs.date == rhs.date &&
            lhs.amount == rhs.amount
    }
}

struct ReleaseScheduleTransactionViewModel: Hashable {
    private var transactionId: String
//    var amount: GTU
    var date: Date
    init(transactionId: String, date: Date) {
        self.transactionId = transactionId
        self.date = date
    }
    func getTransactionHashDisplayValue() -> String {
        let transactionHash = transactionId
        if transactionHash.count < 8 {
            return transactionHash
        }
        let endIndex = transactionHash.index(transactionHash.startIndex, offsetBy: 8)
        return String(transactionHash[..<endIndex])
    }
    
    func getTransactionHashFullHash() -> String {
        return transactionId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(transactionId)
    }
    
    static func == (lhs: ReleaseScheduleTransactionViewModel, rhs: ReleaseScheduleTransactionViewModel) -> Bool {
        lhs.date == rhs.date &&
            lhs.transactionId == rhs.transactionId
    }
}

struct ReleaseScheduleViewModel: Hashable {
    var amount: GTU
    var date: Date
    var transactionIds: [ReleaseScheduleTransactionViewModel]
    
    init(amount: GTU, date: Date, transactionIds: [String]) {
        self.amount = amount
        self.date = date
        self.transactionIds = transactionIds.map { ReleaseScheduleTransactionViewModel(transactionId: $0, date: date)}
    }
}

// MARK: View
protocol ReleaseScheduleViewProtocol: AnyObject {
    func bind(to viewModel: ReleaseScheduleListViewModel)
}

// MARK: Delegate
protocol ReleaseSchedulePresenterDelegate: AnyObject {
}

// MARK: -
// MARK: Presenter
protocol ReleaseSchedulePresenterProtocol: AnyObject {
    var view: ReleaseScheduleViewProtocol? { get set }
    func viewDidLoad()
    
}

class ReleaseSchedulePresenter: ReleaseSchedulePresenterProtocol {
    weak var view: ReleaseScheduleViewProtocol?
    weak var delegate: ReleaseSchedulePresenterDelegate?
 
    private var viewModel = ReleaseScheduleListViewModel()
    
    init(delegate: ReleaseSchedulePresenterDelegate, account: AccountDataType) {
        self.delegate = delegate
        if let releaseSchedule = account.releaseSchedule {
            viewModel = ReleaseScheduleListViewModel(releaseSchedule: releaseSchedule, account: account)
        }
    }
    
    func viewDidLoad() {
        view?.bind(to: viewModel)
    }
}
