//
//  DelegationPoolSelectionPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 08/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

enum DelegationPoolBakerIdError: Error {
    case empty
    case invalid
    case closed
}

enum BakerTarget: Equatable {
    case passive
    case bakerPool(bakerId: Int)
    
    func getDisplayValue() -> String {
        switch self {
        case .passive:
            return "delegation.receipt.passivevalue".localized
        case .bakerPool(let bakerId):
            return String(bakerId)
        }
    }
    
    static func from(delegationType: String, bakerId: Int?) -> BakerTarget {
        if let bakerId = bakerId, delegationType == "Baker" {
            return .bakerPool(bakerId: bakerId)
        } else {
            return .passive
        }
    }
}

// MARK: -
// MARK: Delegate
protocol DelegationPoolSelectionPresenterDelegate: AnyObject {
    func finishedPoolSelection(dataHandler: StakeDataHandler, bakerPoolResponse: BakerPoolResponse?)
    func switchToRemoveDelegator(cost: GTU, energy: Int)
    func pressedClose() 
}

// MARK: -
// MARK: Presenter
protocol DelegationPoolSelectionPresenterProtocol: AnyObject {
	var view: DelegationPoolSelectionViewProtocol? { get set }
    func viewDidLoad()
    func pressedContinue()
    func closeButtonTapped()
}

class DelegationPoolViewModel {
    static let passiveBottomMessage: NSAttributedString = {
        "delegation.pool.bottommessage.passive"
            .localized
            .stringWithHighlightedLinks(
                ["developer.concordium.software": "https://developer.concordium.software/en/mainnet/net/concepts/concepts-delegation.html"]
            )
    }()
    
    static let bakerBottomMessage: NSAttributedString = {
        var stakingLink: String {
            #if MAINNET
            if UserDefaults.bool(forKey: "demomode.userdefaultskey".localized) == true {
                return "delegation.pool.testnetstakinglink".localized
            }
            return "delegation.pool.mainnetstakinglink".localized
            #else
            return "delegation.pool.testnetstakinglink".localized
            #endif
        }
        
        return String(format: "delegation.pool.bottommessage.baker".localized, stakingLink)
            .stringWithHighlightedLinks(
                [stakingLink: stakingLink]
            )
    }()
    
    @Published var title: String = ""
    @Published var message: String = "delegation.pool.message".localized
    @Published var bottomMessage: NSAttributedString = NSAttributedString(string: "")
    @Published var selectedPoolIndex: Int = 0
    @Published var currentValue: String?
    @Published var bakerId: String = ""
    @Published var bakerIdErrorMessage: String?
    @Published var isPoolValid: Bool = false
    
    init(currentPool: BakerTarget?) {
        if let currentPool = currentPool {
            currentValue = String(format: "delegation.pool.current".localized, currentPool.getDisplayValue())
            title = "delegation.pool.title.update".localized
            switch currentPool {
            case .passive:
                bottomMessage = DelegationPoolViewModel.passiveBottomMessage
            case .bakerPool:
                bottomMessage = DelegationPoolViewModel.bakerBottomMessage
            }
        } else {
            title = "delegation.pool.title.create".localized
            bottomMessage = DelegationPoolViewModel.bakerBottomMessage
        }
    }
}

class DelegationPoolSelectionPresenter: DelegationPoolSelectionPresenterProtocol {

    weak var view: DelegationPoolSelectionViewProtocol?
    weak var delegate: DelegationPoolSelectionPresenterDelegate?

    var viewModel: DelegationPoolViewModel
    @Published private var validSelectedPool: BakerTarget?
    @Published private var bakerPoolResponse: BakerPoolResponse?

    private let account: AccountDataType
    private var dataHandler: StakeDataHandler
    private var cancellables = Set<AnyCancellable>()
    private var stakeService: StakeServiceProtocol
    private let transactionService: TransactionsServiceProtocol
    
    init(account: AccountDataType,
         delegate: DelegationPoolSelectionPresenterDelegate? = nil,
         dependencyProvider: StakeCoordinatorDependencyProvider,
         dataHandler: StakeDataHandler) {
        self.account = account
        self.delegate = delegate
        self.stakeService = dependencyProvider.stakeService()
        self.transactionService = dependencyProvider.transactionsService()
        let currentPoolData: PoolDelegationData? = dataHandler.getCurrentEntry()
        self.viewModel = DelegationPoolViewModel(currentPool: currentPoolData?.pool)
        if let pool = currentPoolData?.pool {
            self.validSelectedPool = pool
            if case BakerTarget.passive = pool {
                self.viewModel.selectedPoolIndex = 1
            }
        }
        self.dataHandler = dataHandler
    }
    
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        self.view?.bakerIdPublisher
            .compactMap { [weak self] bakerId -> String in
                self?.validSelectedPool = nil
                return bakerId
            }
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .flatMap { [weak self] bakerId -> AnyPublisher<Result<Int, DelegationPoolBakerIdError>, Never> in
                return self?.fetchBakerPool(bakerId: bakerId) ?? .just(.failure(.invalid))
            }
            .sink { [weak self]  result in
                self?.receiveBakerPoolResponse(result)
            }.store(in: &cancellables)
        
        self.view?.poolOption.sink(receiveCompletion: { _ in
        }, receiveValue: { [weak self] selectedOption in
            guard let self = self else { return }
            self.viewModel.selectedPoolIndex = selectedOption
            self.viewModel.bakerIdErrorMessage = nil
            if selectedOption == 1 {
                self.validSelectedPool = .passive
                self.viewModel.bakerId = ""
                self.viewModel.bottomMessage = DelegationPoolViewModel.passiveBottomMessage
            } else {
                // we reset to the current baker pool
                self.viewModel.bakerId = ""
                _ = self.resetToCurrentBakerPool()
                self.viewModel.bottomMessage = DelegationPoolViewModel.bakerBottomMessage
            }
        }).store(in: &cancellables)
        
        self.$validSelectedPool
            .sink { pool in
            self.viewModel.isPoolValid = (pool != nil)
        }.store(in: &cancellables)
    }
    
    private func fetchBakerPool(bakerId: String) -> AnyPublisher<Result<Int, DelegationPoolBakerIdError>, Never> {
        self.viewModel.bakerId = bakerId
        
        if bakerId.isEmpty {
            return .just(self.resetToCurrentBakerPool())
        }
        
        guard let bakerIdInt = Int(bakerId) else {
            return .just(Result.failure(DelegationPoolBakerIdError.invalid))
        }
       
        return self.stakeService.getBakerPool(bakerId: bakerIdInt)
            .showLoadingIndicator(in: self.view)
            .map { [weak self] response in
                self?.bakerPoolResponse = response
                let currentBakerId = self?.getCurrentBakerId()
                if (response.poolInfo.openStatus == "openForAll") ||
                    (response.poolInfo.openStatus == "closedForNew" && currentBakerId == bakerIdInt) {
                    return Result<Int, DelegationPoolBakerIdError>.success(bakerIdInt)
                } else {
                    return Result<Int, DelegationPoolBakerIdError>.failure(DelegationPoolBakerIdError.closed)
                }
            }.replaceError(with: {
                return Result<Int, DelegationPoolBakerIdError>.failure(DelegationPoolBakerIdError.invalid)
            }())
            .eraseToAnyPublisher()
    }
    
    private func receiveBakerPoolResponse(_ result: Result<Int, DelegationPoolBakerIdError>) {
        switch result {
        case Result.success(let bakerId):
            self.validSelectedPool = .bakerPool(bakerId: bakerId)
            self.viewModel.bakerIdErrorMessage = nil
        case .failure(let error):
            self.validSelectedPool = nil
            switch error {
            case .empty:
                self.viewModel.bakerIdErrorMessage = nil
            case .invalid:
                self.viewModel.bakerIdErrorMessage = "delegation.pool.invalidbakerid".localized
            case .closed:
                self.viewModel.bakerIdErrorMessage = "delegation.pool.closedpool".localized
            }
        }
    }
    
    func pressedContinue() {
        // the pool will be valid at this point as the buttonn is only enabled
        // if the pool is valid
        guard let validPool = self.validSelectedPool else { return }
        
        if case .bakerPool(let bakerId) = validPool {
            // we use whichever is available first, either the variable or
            // the response from the network
            Publishers.Merge(self.stakeService.getBakerPool(bakerId: bakerId),
                             self.$bakerPoolResponse
                                .compactMap { $0 }
                                .setFailureType(to: Error.self))
                .first()
                .showLoadingIndicator(in: self.view)
                .sink(receiveError: { error in
                    self.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                }, receiveValue: { bakerPoolResponse in
                    if self.shouldShowPoolSizeWarning(response: bakerPoolResponse) {
                        self.showPoolSizeWarning(response: bakerPoolResponse)
                    } else {
                        self.dataHandler.add(entry: PoolDelegationData(pool: validPool))
                        self.delegate?.finishedPoolSelection(
                            dataHandler: self.dataHandler,
                            bakerPoolResponse: bakerPoolResponse
                        )
                    }
                })
                .store(in: &cancellables)
        } else {
            self.dataHandler.add(entry: PoolDelegationData(pool: validPool))
            self.delegate?.finishedPoolSelection(
                dataHandler: self.dataHandler,
                bakerPoolResponse: nil
            )
        }
    }
    
    private func shouldShowPoolSizeWarning(response: BakerPoolResponse) -> Bool {
        // The alert should only be shown if you are not currently in cooldown and bakerId is different
        guard let delegation = self.account.delegation,
              delegation.pendingChange?.change == .NoChange,
              delegation.delegationTargetBakerID.string != viewModel.bakerId else {
            return false
        }
        
        guard let poolLimit = GTU(intValue: Int(response.delegatedCapitalCap)),
              let delegatedCapital = GTU(intValue: Int(response.delegatedCapital)) else {
            return false
        }
        
        return GTU(intValue: delegation.stakedAmount) + delegatedCapital > poolLimit
    }
    
    private func showPoolSizeWarning(response: BakerPoolResponse) {
        let lowerAmountAction = AlertAction(
            name: "delegation.pool.sizewarning.loweramount".localized,
            completion: {
                self.delegate?.finishedPoolSelection(
                    dataHandler: self.dataHandler,
                    bakerPoolResponse: response
                )
            }, style: .default
        )
        let stopDelegationAction = AlertAction(
            name: "delegation.pool.sizewarning.stopdelegation".localized,
            completion: {
                self.transactionService
                    .getTransferCost(transferType: .removeDelegation, costParameters: [])
                    .showLoadingIndicator(in: self.view)
                    .sink { error in
                        self.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                    } receiveValue: { transferCost in
                        let cost = GTU(intValue: Int(transferCost.cost) ?? 0)
                        self.delegate?.switchToRemoveDelegator(cost: cost, energy: transferCost.energy)
                    }
                    .store(in: &self.cancellables)

            }, style: .default
        )
        let cancelAction = AlertAction(
            name: "delegation.pool.sizewarning.cancel".localized,
            completion: nil,
            style: .default
        )
        
        let alertOptions = AlertOptions(
            title: "delegation.pool.sizewarning.title".localized,
            message: "delegation.pool.sizewarning.message".localized,
            actions: [lowerAmountAction, stopDelegationAction, cancelAction]
        )
        
        self.view?.showAlert(with: alertOptions)
    }
    
    func closeButtonTapped() {
        self.delegate?.pressedClose()
    }
    
    // MARK: - Helper methods
    func getCurrentBakerId() -> Int? {
        let poolData: PoolDelegationData? = self.dataHandler.getCurrentEntry()
        let bakerPool = poolData?.pool
        var currentBakerId: Int?
        if case let .bakerPool(bakerId) = bakerPool {
            currentBakerId = bakerId
        }
        return currentBakerId
    }
    
    func resetToCurrentBakerPool() -> Result<Int, DelegationPoolBakerIdError> {
        guard let currentPoolData: PoolDelegationData = dataHandler.getCurrentEntry() else {
            self.validSelectedPool = nil
            return .failure(.empty)
        }
        if case let BakerTarget.bakerPool(bakerId) = currentPoolData.pool {
            self.validSelectedPool = currentPoolData.pool
            return Result.success(bakerId)
        } else {
            self.validSelectedPool = nil
            return Result.failure(.empty)
        }
    }
}
