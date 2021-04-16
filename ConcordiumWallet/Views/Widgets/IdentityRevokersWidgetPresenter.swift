//
//  IdentityRevokersWidgetPresenter.swift
//  ConcordiumWallet
//
//  Created by Johan Rugager Vase on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: View -
protocol IdentityRevokersWidgetViewProtocol: class {
}

// MARK: Presenter -
protocol IdentityRevokersWidgetPresenterProtocol: class {
	var view: IdentityRevokersWidgetViewProtocol? { get set }
}

class IdentityRevokersWidgetPresenter: IdentityRevokersWidgetPresenterProtocol {
    weak var view: IdentityRevokersWidgetViewProtocol?
}
