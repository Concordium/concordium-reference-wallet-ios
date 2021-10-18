//
//  CopyReferenceInfoWidgetPresenter.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 15/10/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

// MARK: - Presenter

protocol CopyReferenceInfoWidgetPresenterProtocol {
    var view: CopyReferenceInfoWidgetViewProtocol? { get set }
    func viewDidLoad()
}

class CopyReferenceInfoWidgetPresenter: CopyReferenceInfoWidgetPresenterProtocol {
    var view: CopyReferenceInfoWidgetViewProtocol?
    func viewDidLoad() {}
}
