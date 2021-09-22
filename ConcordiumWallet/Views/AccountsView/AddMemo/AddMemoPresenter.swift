//
//  AddMemoPresenter.swift
//  Mock
//
//  Created by Kristiyan Dobrev on 22/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

// MARK: - View
protocol AddMemoViewProtocol: ShowError {
    func bind(to: AddMemoViewModel)
}

// MARK: - Delegate
protocol AddMemoPresenterDelegate: AnyObject {
    func addMemoDidAddMemoToTransfer(memo: String)
}

// MARK: - Presenter
protocol AddMemoPresenterProtocol: AnyObject {
    var view: AddMemoViewProtocol? { get set }
    func viewDidLoad()
    func userTappedAddMemoToTransfer(memo: String)
}

class AddMemoViewModel {
    @Published var memo: String = ""
    @Published var enableAddMemoToTransferButton = false
    @Published var showMemoError = false
}

class AddMemoPresenter {
 
    weak var view: AddMemoViewProtocol?
    weak var delegate: AddMemoPresenterDelegate?
    var viewModel = AddMemoViewModel()
    
    init(delegate: AddMemoPresenterDelegate? = nil) {
        self.delegate = delegate
    }
    
    func viewDidLoad() {
        view?.bind(to: viewModel)
    }
}

extension AddMemoPresenter: AddMemoPresenterProtocol {
    func userTappedAddMemoToTransfer(memo: String) {
        
    }
}
