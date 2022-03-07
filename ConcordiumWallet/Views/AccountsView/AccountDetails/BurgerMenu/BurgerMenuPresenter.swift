//
//  BurgerMenuPresenter.swift
//  ConcordiumWallet
//
//  Concordium on 04/12/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

protocol BurgerMenuAction {
    func getDisplayName() -> String
}

class BurgerMenuViewModel {
    
    @Published var displayActions: [String] = []
    
    func setup(actions: [BurgerMenuAction]) {
        displayActions = actions.map { $0.getDisplayName() }
    }
}

// MARK: View
protocol BurgerMenuViewProtocol: AnyObject {
    func bind(to viewModel: BurgerMenuViewModel)
}

// MARK: Presenter
protocol BurgerMenuPresenterProtocol: AnyObject {
    var view: BurgerMenuViewProtocol? { get set }
    func viewDidLoad()
    func pressedDismiss()
    func selectedAction(at index: Int)
}
