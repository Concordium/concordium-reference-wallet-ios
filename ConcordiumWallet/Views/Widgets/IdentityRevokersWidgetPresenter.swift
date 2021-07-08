//
//  IdentityRevokersWidgetPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: View -
protocol IdentityRevokersWidgetViewProtocol: AnyObject {
}

// MARK: Presenter -
protocol IdentityRevokersWidgetPresenterProtocol: AnyObject {
	var view: IdentityRevokersWidgetViewProtocol? { get set }
}

class IdentityRevokersWidgetPresenter: IdentityRevokersWidgetPresenterProtocol {
    weak var view: IdentityRevokersWidgetViewProtocol?
}
