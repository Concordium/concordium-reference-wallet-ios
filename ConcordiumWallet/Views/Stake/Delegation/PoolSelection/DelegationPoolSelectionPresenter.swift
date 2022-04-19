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
}

enum BakerPool {
    case lpool
    case bakerPool(bakerId: Int)
    
    func getDisplayValue() -> String {
        switch self {
        case .lpool:
            return "delegation.receipt.lpoolvalue".localized
        case .bakerPool(let bakerId):
            return String(format: "delegation.receipt.bakerpoolvalue".localized, bakerId)
        }
    }
    
    static func from(delegationType: String, bakerId: Int?) -> BakerPool {
        if let bakerId = bakerId, delegationType == "Baker" {
            return .bakerPool(bakerId: bakerId)
        } else {
            return .lpool
        }
    }
}

// MARK: -
// MARK: Delegate
protocol DelegationPoolSelectionPresenterDelegate: AnyObject {
    func finishedPoolSelection(bakerPoolResponse: BakerPoolResponse?)
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
    @Published var title: String = ""
    @Published var message: String = "delegation.pool.message".localized
    @Published var bottomMessage: String = "delegation.pool.bottommessage".localized
    @Published var selectedPoolIndex: Int = 0
    @Published var currentValue: String?
    @Published var bakerId: String = ""
    @Published var bakerIdErrorMessage: String?
    @Published var isPoolValid: Bool = false
    
    init(currentPool: BakerPool?) {
        if let currentPool = currentPool {
            currentValue = String(format: "delegation.pool.current".localized, currentPool.getDisplayValue())
            title = "delegation.pool.title.update".localized
        } else {
            title = "delegation.pool.title.create".localized
        }
    }
}

class DelegationPoolSelectionPresenter: DelegationPoolSelectionPresenterProtocol {

    weak var view: DelegationPoolSelectionViewProtocol?
    weak var delegate: DelegationPoolSelectionPresenterDelegate?

    var viewModel: DelegationPoolViewModel
    @Published private var validSelectedPool: BakerPool?
    @Published private var bakerPoolResponse: BakerPoolResponse?

    private var dataHandler: StakeDataHandler
    private var cancellables = Set<AnyCancellable>()
    private var stakeService: StakeServiceProtocol
    
    init(delegate: DelegationPoolSelectionPresenterDelegate? = nil,
         dependencyProvider: StakeCoordinatorDependencyProvider,
         dataHandler: StakeDataHandler) {
        self.delegate = delegate
        self.stakeService = dependencyProvider.stakeService()
        let currentPoolData: PoolDelegationData? = dataHandler.getCurrentEntry()
        self.viewModel = DelegationPoolViewModel(currentPool: currentPoolData?.pool)
        if let pool = currentPoolData?.pool {
            self.validSelectedPool = pool
            if case BakerPool.lpool = pool {
                self.viewModel.selectedPoolIndex = 1
            }
        }
        self.dataHandler = dataHandler
    }

    // swiftlint:disable function_body_length
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        self.view?.bakerIdPublisher
            .compactMap { [weak self] bakerId -> String in
                self?.validSelectedPool = nil
                return bakerId
            }
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .flatMap { [weak self] bakerId -> AnyPublisher<Result<Int, DelegationPoolBakerIdError>, Never> in
                self?.viewModel.bakerId = bakerId
                guard let self = self else {
                    return .just(Result.failure(DelegationPoolBakerIdError.invalid))
                }
                if bakerId.isEmpty {
                    return .just(Result.failure(DelegationPoolBakerIdError.empty))
                }
                guard let bakerIdInt = Int(bakerId) else {
                    return .just(Result.failure(DelegationPoolBakerIdError.invalid))
                }
               
                return self.stakeService.getBakerPool(bakerId: bakerIdInt)
                    .showLoadingIndicator(in: self.view)
                    .map { [weak self] response in
                        self?.bakerPoolResponse = response
                        let currentBakerId = self?.getCurrentBakerId()
                        if (response.poolInfo.openStatus == "openForAll") || (response.poolInfo.openStatus == "closedForNew" && currentBakerId == bakerIdInt) {
                            return Result<Int, DelegationPoolBakerIdError>.success(bakerIdInt)
                        } else {
                            return Result<Int, DelegationPoolBakerIdError>.failure(DelegationPoolBakerIdError.invalid)
                        }
                    }.replaceError(with: {
                        return Result<Int, DelegationPoolBakerIdError>.failure(DelegationPoolBakerIdError.invalid)
                    }())
                    .eraseToAnyPublisher()
        } .sink(receiveCompletion: { _ in
        }, receiveValue: { [weak self]  result in
            switch result {
            case Result.success(let bakerId):
                self?.validSelectedPool = .bakerPool(bakerId: bakerId)
                self?.viewModel.bakerIdErrorMessage = nil
            case .failure(let error):
                self?.validSelectedPool = nil
                switch error {
                case .empty:
                    self?.viewModel.bakerIdErrorMessage = nil
                case .invalid:
                    self?.viewModel.bakerIdErrorMessage = "delegation.pool.invalidbakerid".localized
                }
                
            }
        }).store(in: &cancellables)
        
        self.view?.poolOption.sink(receiveCompletion: { _ in
        }, receiveValue: { [weak self] selectedOption in
            guard let self = self else { return }
            self.viewModel.selectedPoolIndex = selectedOption
            self.viewModel.bakerIdErrorMessage = nil
            if selectedOption == 1 {
                self.validSelectedPool = .lpool
                self.viewModel.bakerId = ""
            } else {
                // we only have a valid baker pool after a valid baker id is set
                // for the baker pool
                self.validSelectedPool = nil
            }
        }).store(in: &cancellables)
        
        self.$validSelectedPool
            .sink { pool in
            self.viewModel.isPoolValid = (pool != nil)
        }.store(in: &cancellables)
    }
    
    func pressedContinue() {
        // the pool will be valid at this point as the buttonn is only enabled
        // if the pool is valid
        guard let validPool = self.validSelectedPool else { return }
        self.dataHandler.add(entry: PoolDelegationData(pool: validPool))
        
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
                    self.delegate?.finishedPoolSelection(bakerPoolResponse: bakerPoolResponse)
                })
                .store(in: &cancellables)
        } else {
            self.delegate?.finishedPoolSelection(bakerPoolResponse: nil)
        }
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
}
