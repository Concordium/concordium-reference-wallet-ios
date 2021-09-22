//
//  AddMemoPresenter.swift
//  Mock
//
//  Created by Kristiyan Dobrev on 22/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Combine
import Foundation

// MARK: - View
protocol AddMemoViewProtocol: ShowError {
    func bind(to: AddMemoViewModel)
    var pageTitle: String? { get set }
    var memoTitleLabelText: String? { get set }
    var memoTextViewPlaceholderText: String? { get set }
    var buttonTitle: String? { get set }
    var memoPublisher: AnyPublisher<String, Never> { get }
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
    @Published var memo: Memo?
    @Published var enableAddMemoToTransferButton = false
    @Published var invalidMemoSizeError = false
    @Published var shakeTextView = false
}

class AddMemoPresenter {
    
    weak var view: AddMemoViewProtocol?
    weak var delegate: AddMemoPresenterDelegate?
 
    private var cancellables = [AnyCancellable]()

    private var viewModel = AddMemoViewModel()
    
    @Published private var memo: Memo?
    
    init(delegate: AddMemoPresenterDelegate? = nil) {
        self.delegate = delegate
    }
    
    func viewDidLoad() {
        view?.pageTitle = "addMemo.pageTitle".localized
        view?.memoTitleLabelText = "addMemo.memoTitle".localized
        view?.memoTextViewPlaceholderText = "addMemo.memoTextViewPlaceholder".localized
        view?.buttonTitle = "addMemo.addMemoButtonTitle".localized
        
        view?.memoPublisher
            .map { Memo(memo: $0) }
            .assign(to: \.memo, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.$memo
            .compactMap { $0 }
            .map { !$0.isSizeValid }
            .assign(to: \.invalidMemoSizeError, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.$memo
            .withPrevious()
            .map {
                guard
                    let previous = $0.previous,
                    let current = $0.current,
                    !current.isSizeValid
                else {
                    return false
                }
                
                return current.size >= (previous?.size ?? 0)
            }
            .assign(to: \.shakeTextView, on: viewModel)
            .store(in: &cancellables)
        
        
        viewModel.$memo
            .compactMap { $0 }
            .map { !$0.memo.isEmpty && $0.isSizeValid }
            .assign(to: \.enableAddMemoToTransferButton, on: viewModel)
            .store(in: &cancellables)
        
        
        view?.bind(to: viewModel)
    }
}

extension AddMemoPresenter: AddMemoPresenterProtocol {
    func userTappedAddMemoToTransfer(memo: String) {
        
    }
}
