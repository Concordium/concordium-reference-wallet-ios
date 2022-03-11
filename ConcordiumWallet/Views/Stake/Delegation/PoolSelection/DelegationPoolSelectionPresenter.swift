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
    case invalid
}

enum BakerPool {
    case lpool
    case bakerPool(bakerId: String)
    
    func getDisplayValue() -> String {
        switch self {
        case .lpool:
            return "delegation.receipt.lpoolvalue".localized
        case .bakerPool(let bakerId):
            return String(format: "delegation.receipt.bakerpoolvalue".localized, bakerId)
        }
    }
}

// MARK: -
// MARK: Delegate
protocol DelegationPoolSelectionPresenterDelegate: AnyObject {
    func finishedPoolSelection()
}

// MARK: -
// MARK: Presenter
protocol DelegationPoolSelectionPresenterProtocol: AnyObject {
	var view: DelegationPoolSelectionViewProtocol? { get set }
    func viewDidLoad()
    func pressedContinue()
}

class DelegationPoolViewModel {
    @Published var title: String = ""
    @Published var message: String = "delegation.pool.message".localized
    @Published var bottomMessage: String = "delegation.pool.bottommessage".localized
    @Published var selectedPoolIndex: Int = 0
    @Published var currentValue: String? = nil
    @Published var bakerId: String = ""
    @Published var bakerIdErrorMessage: String? = nil
    @Published var isPoolValid: Bool = false
    
    init(currentPool: BakerPool?) {
        if let currentPool = currentPool {
            currentValue = String(format:"delegation.pool.current".localized, currentPool.getDisplayValue())
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

    private var dataHandler: DelegationDataHandler
    private var cancellables = Set<AnyCancellable>()
    
    init(delegate: DelegationPoolSelectionPresenterDelegate? = nil, dataHandler: DelegationDataHandler) {
        self.delegate = delegate
        let currentPoolData: PoolDelegationData? = dataHandler.getCurrentEntry()
        self.viewModel = DelegationPoolViewModel(currentPool: currentPoolData?.pool)
        self.dataHandler = dataHandler
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        self.view?.bakerIdPublisher
            .flatMap { [weak self] bakerId -> AnyPublisher<Result<String, DelegationPoolBakerIdError>, Never> in
                self?.viewModel.bakerId = bakerId
                
            //TODO: check if the baker id is valid
                if bakerId == "4" {
                    return .just(Result.failure(DelegationPoolBakerIdError.invalid))
                }
            return .just(.success(bakerId)).eraseToAnyPublisher()
        } .sink(receiveCompletion: { completion in
        }, receiveValue: { [weak self]  result in
            switch result {
            case Result.success(let bakerId):
                self?.validSelectedPool = .bakerPool(bakerId: bakerId)
                self?.viewModel.bakerIdErrorMessage = nil
            case .failure(_):
                self?.validSelectedPool = nil
                self?.viewModel.bakerIdErrorMessage = "delegation.pool.invalidbakerid".localized
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
                //we only have a valid baker pool after a valid baker id is set
                //for the baker pool
                self.validSelectedPool = nil
            }
        }).store(in: &cancellables)
        
        self.$validSelectedPool.sink { pool in
            self.viewModel.isPoolValid = (pool != nil)
        }.store(in: &cancellables)
        
    }
    
    func pressedContinue() {
        //the pool will be valid at this point as the buttonn is only enabled
        //if the pool is valid
        guard let validPool = self.validSelectedPool else { return }
        self.dataHandler.add(entry: PoolDelegationData(pool: validPool))
        
        self.delegate?.finishedPoolSelection()
    }
}
