//
//  SelectAccountPresenter.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 3.4.23.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation

// MARK: View
protocol SelectAccountViewProtocol: AnyObject {
}

// MARK: -
// MARK: Presenter
protocol SelectAccountPresenterProtocol: AnyObject {
    var view: SelectAccountViewProtocol? { get set }
    
    func viewDidLoad()
}

class SelectAccountPresenter: SelectAccountPresenterProtocol {

    weak var view: SelectAccountViewProtocol?

    func viewDidLoad() {
    }
}
