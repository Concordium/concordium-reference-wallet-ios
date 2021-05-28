//
//  ReleaseScheduleEntity.swift
//  ConcordiumWallet
//
//  Concordium on 23/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol ReleaseScheduleDataType: DataStoreProtocol {
    var schedule: [ScheduleDataType] { get set }
    var total: Int { get set }
}

final class ReleaseScheduleEntity: Object {
  
    var scheduleList = List<ScheduleEntity>()
    @objc dynamic var total: Int = 0

    convenience init(from accountReleaseSchedule: AccountReleaseSchedule?) {
        self.init()
        self.total = Int(accountReleaseSchedule?.total ?? "0") ?? 0

        self.schedule = accountReleaseSchedule?.schedule?.map { (schedule: Schedule) -> ScheduleEntity in
            let transactions = List<String>()
            transactions.append(objectsIn: schedule.transactions ?? [])
            return ScheduleEntity(transactionList: transactions, amount: schedule.amount, timestamp: schedule.timestamp ?? 0)
        } ?? []
    }
}

extension ReleaseScheduleEntity: ReleaseScheduleDataType {

    var schedule: [ScheduleDataType] {
        get {
            scheduleList.map { (elem) -> ScheduleDataType in
                elem
            }
        }
        set {
            
            let newArray = newValue.map { (scheduleDataType) -> ScheduleEntity in
                let transactions = List<String>()
                transactions.append(objectsIn: scheduleDataType.transactions)
                return ScheduleEntity(transactionList: transactions, amount: scheduleDataType.amount, timestamp: scheduleDataType.timestamp)
            }
            
            scheduleList.removeAll()
            scheduleList.append(objectsIn: newArray)
        }
    }
}
