//
//  DelegationPoolSelectionPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 08/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

//Add this to your coordinator:
//    func showDelegationPoolSelection() {
//        let vc = DelegationPoolSelectionFactory.create(with: DelegationPoolSelectionPresenter(delegate: self))
//        navigationController.pushViewController(vc, animated: false)
//    }

enum DelegationPoolBakerIdError: Error {
    case invalid
}

enum BakerPool {
    case lpool
    case bakerPool(bakerId: String)
}

// MARK: -
// MARK: Delegate
protocol DelegationPoolSelectionPresenterDelegate: AnyObject {

}

// MARK: -
// MARK: Presenter
protocol DelegationPoolSelectionPresenterProtocol: AnyObject {
	var view: DelegationPoolSelectionViewProtocol? { get set }
    func viewDidLoad()
}

struct DelegationPoolViewModel {
    var bakerIdErrorMessage: String? = nil
}


class DelegationPoolSelectionPresenter: DelegationPoolSelectionPresenterProtocol {

    weak var view: DelegationPoolSelectionViewProtocol?
    weak var delegate: DelegationPoolSelectionPresenterDelegate?

    var viewModel: DelegationPoolViewModel
    
    var validBakerId: String?
    var validSelectedPool: BakerPool?
    
    init(delegate: DelegationPoolSelectionPresenterDelegate? = nil) {
        self.delegate = delegate
        self.viewModel = DelegationPoolViewModel()
    }

    func viewDidLoad() {
        self.view?.bakerIdPublisher
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .flatMap { bakerId -> AnyPublisher<Result<String, DelegationPoolBakerIdError>, Never> in
            //TODO: check if the baker id is valid
                //self?.viewModel.bakerIdErrorMessage = "".localized
            return .just(.success(bakerId)).eraseToAnyPublisher()
        } .sink(receiveCompletion: { completion in
        }, receiveValue: { [weak self]  result in
            if case Result.success(let bakerId) = result {
                self?.validSelectedPool = .bakerPool(bakerId: bakerId)
                self?.viewModel.bakerIdErrorMessage = nil
            }
        })
        
        self.view?.bind(viewModel: viewModel)
    }
}
