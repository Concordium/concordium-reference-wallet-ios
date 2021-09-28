//
//  AboutPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 18/02/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import Combine
import UIKit

// MARK: View
protocol AboutViewProtocol: ShowAlert {
}

// MARK: -
// MARK: Delegate
protocol AboutPresenterDelegate: AnyObject {
}

// MARK: -
// MARK: Presenter
protocol AboutPresenterProtocol: AnyObject {
    var view: AboutViewProtocol? { get set }
    func viewDidLoad()
}

class AboutPresenter: AboutPresenterProtocol {
    weak var view: AboutViewProtocol?
    weak var delegate: AboutPresenterDelegate?
    private var cancellables: [AnyCancellable] = []
    
    init(delegate: AboutPresenterDelegate?) {
        self.delegate = delegate
    }

    func viewDidLoad() {
    }
}
