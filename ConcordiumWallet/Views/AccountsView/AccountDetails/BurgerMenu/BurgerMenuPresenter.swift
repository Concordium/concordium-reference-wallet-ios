//
//  BurgerMenuPresenter.swift
//  ConcordiumWallet
//
//  Concordium on 04/12/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

protocol BurgerMenuAction {
    var destructive: Bool { get }
    var enabled: Bool { get }
    
    func getDisplayName() -> String
}

extension BurgerMenuAction {
    var destructive: Bool { false }
    var enabled: Bool { true }
}

class BurgerMenuViewModel {
    struct Action: Hashable {
        let displayName: String
        let destructive: Bool
        let enabled: Bool
        
        init(burgerMenuAction: BurgerMenuAction) {
            displayName = burgerMenuAction.getDisplayName()
            destructive = burgerMenuAction.destructive
            enabled = burgerMenuAction.enabled
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(displayName)
        }
    }
    
    @Published var displayActions: [Action] = []
    
    func setup(actions: [BurgerMenuAction]) {
        displayActions = actions.map(Action.init(burgerMenuAction:))
    }
}

// MARK: View
protocol BurgerMenuViewProtocol: ShowAlert, Loadable {
    func bind(to viewModel: BurgerMenuViewModel)
}

// MARK: Presenter
protocol BurgerMenuPresenterProtocol: AnyObject {
    var view: BurgerMenuViewProtocol? { get set }
    func viewDidLoad()
    func pressedDismiss()
    func selectedAction(at index: Int)
}
