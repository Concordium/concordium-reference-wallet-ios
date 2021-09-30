//
//  GettingStartedInfoPresenter.swift
//  ConcordiumWallet
//
//  Concordium on 11/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: ViewModel
struct InitialAccountInfoViewModel {
    var title: String
    var subtitle: String
    var details: String
    var buttonTitle: String
    var showsClose: Bool = true
}

enum InitialAccountInfoType {
    case firstAccount
    case newAccount
    case importAccount
    case welcomeScreen
    
    func getViewModel() -> InitialAccountInfoViewModel {
        switch self {
        case .firstAccount:
            return InitialAccountInfoViewModel(title: "initialaccountinfo.title".localized,
                                               subtitle: "initialaccountinfo.subtitle".localized,
                                               details: "initialaccountinfo.firstidentity.details".localized,
                                               buttonTitle: "okay.gotit".localized)
        case .newAccount:
            return InitialAccountInfoViewModel(title: "initialaccountinfo.title".localized,
                                               subtitle: "initialaccountinfo.subtitle".localized,
                                               details: "initialaccountinfo.details".localized,
                                               buttonTitle: "okay.gotit".localized)
        case .importAccount:
            return InitialAccountInfoViewModel(title: "importinfo.title".localized,
                                               subtitle: "importinfo.subtitle".localized,
                                               details: "importinfo.details".localized,
                                               buttonTitle: "okay.gotit".localized,
                                               showsClose: false)
        case .welcomeScreen:
            return InitialAccountInfoViewModel(title: "welcomeScreen.title".localized,
                                               subtitle: "welcomeScreen.subtitle".localized,
                                               details: "welcomeScreen.details".localized,
                                               buttonTitle: "welcomeScreen.button".localized,
                                               showsClose: false)
        }
    }
}

// MARK: View
protocol InitialAccountInfoViewProtocol: ShowAlert {
      func bind(to viewModel: InitialAccountInfoViewModel)
}

protocol InitialAccountInfoPresenterProtocol: AnyObject {
    var view: InitialAccountInfoViewProtocol? { get set }
    func userTappedOK()
    func userTappedClose()
    func viewDidLoad()
}

// MARK: -
// MARK: Delegate
protocol InitialAccountInfoPresenterDelegate: AnyObject {
    func userTappedOK(withType: InitialAccountInfoType)
    func userTappedClose()
}

class InitialAccountInfoPresenter {
    weak var view: InitialAccountInfoViewProtocol?
    weak var delegate: InitialAccountInfoPresenterDelegate?
    
    private var viewModel: InitialAccountInfoViewModel
    var type: InitialAccountInfoType
    init(delegate: InitialAccountInfoPresenterDelegate? = nil,
         type: InitialAccountInfoType) {
        self.delegate = delegate
        viewModel = type.getViewModel()
        self.type = type
    }
    
    func viewDidLoad() {
        view?.bind(to: viewModel)
    }
}

extension InitialAccountInfoPresenter: InitialAccountInfoPresenterProtocol {
    func userTappedOK() {
        delegate?.userTappedOK(withType: type)
    }
    func userTappedClose() {
        delegate?.userTappedClose()
    }
}
