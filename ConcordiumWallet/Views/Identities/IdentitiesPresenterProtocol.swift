//
//  IdentitiesPresenterProtocol.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/19/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol IdentitiesPresenterProtocol: AnyObject {
    var view: IdentitiesViewProtocol? { get set }
    
    func getTitle() -> String
    
    func viewWillAppear()

    var identities: [IdentityDataType] { get set }

    func viewModelsCount() -> Int
    func identityViewModel(index: Int) -> IdentityInfoViewModel?
    func userSelectedIdentity(index: Int)
    
    func createIdentitySelected()

    func cancel()
    func refresh(pendingIdentity: IdentityDataType?)
}

/// Handle the shared logic between identities and chooseIdentities presenters
/// Note: empty functions to allow subclasses to override implemenation
class IdentityGeneralPresenter: IdentitiesPresenterProtocol {
    func getTitle() -> String {
        ""
    }
    
    func viewWillAppear() {
    }

    func refresh(pendingIdentity: IdentityDataType? = nil) {
    }

    func userSelectedIdentity(index: Int) {
    }
    
    weak var view: IdentitiesViewProtocol?
    
    var viewModels = [IdentityInfoViewModel]() {
        didSet {
            let toShowCreateIdentityView = viewModels.count == 0
            view?.showCreateIdentityView(show: toShowCreateIdentityView)
            if !toShowCreateIdentityView {
                self.view?.reloadView()
            }
        }
    }
    
    var identities = [IdentityDataType]() {
           didSet {
               self.viewModels = identities.compactMap(IdentityInfoViewModel.init)
               self.view?.reloadView()
           }
       }
    
    func viewModelsCount() -> Int {
        viewModels.count
    }

    func identityViewModel(index: Int) -> IdentityInfoViewModel? {
        guard index < viewModels.count else {
            return nil
        }
        return viewModels[index]
    }
    
    // Providing default implementation because it is optional
    func cancel() {
    }
    
    func createIdentitySelected() {
    }
}
