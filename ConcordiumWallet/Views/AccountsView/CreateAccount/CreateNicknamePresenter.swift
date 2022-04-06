//
//  CreateNicknamePresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/15/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: - View Model

final class CreateNicknameViewModel {
    @Published var name: String?
    @Published var enableCtaButton = false
    @Published var invalidLengthError = false
    @Published var shakeTextView = false
}

// MARK: View
protocol CreateNicknameViewProtocol: ShowAlert {
    func setNickname(_: String)
    func setProperties(_: CreateNicknameProperties)
    func showKeyboard()
    func bind(to viewModel: CreateNicknameViewModel)
    var namePublisher: AnyPublisher<String, Never> { get }
}

// MARK: -
// MARK: Delegate
protocol CreateNicknamePresenterDelegate: AnyObject {
    func createNicknamePresenterCancelled(_: CreateNicknamePresenter)
    func createNicknamePresenter(_: CreateNicknamePresenter, didCreateName: String, properties: CreateNicknameProperties)
}

protocol CreateNicknameProperties {
    var title: String { get }
    var subtitle: String { get }
    var details: String { get }
    var textFieldPlaceholder: String { get }
    var button: String { get }
    var errorInvalid: ViewError { get }
}

struct CreateInitialAccountNicknameProperties: CreateNicknameProperties {
    private(set) var title: String = "createNickname.initialaccount.title".localized
    private(set) var subtitle: String = "createNickname.initialaccount.subtitle".localized
    private(set) var details: String = "createNickname.initialaccount.details".localized
    private(set) var button: String = "createNickname.initialaccount.button".localized
    private(set) var textFieldPlaceholder: String = "createNickname.initialaccount.nicknameField.placeholder".localized
    private (set) var errorInvalid: ViewError = ViewError.invalidAccountName
}

struct CreateAccountNicknameProperties: CreateNicknameProperties {
    private(set) var title: String = "createNickname.account.title".localized
    private(set) var subtitle: String = "createNickname.account.subtitle".localized
    private(set) var details: String = "createNickname.account.details".localized
    private(set) var button: String = "createNickname.account.button".localized
    private(set) var textFieldPlaceholder: String = "createNickname.account.nicknameField.placeholder".localized
    private (set) var errorInvalid: ViewError = ViewError.invalidAccountName
}

struct CreateIdentityNicknameProperties: CreateNicknameProperties {
    private(set) var title: String = "createNickname.identity.title".localized
    private(set) var subtitle: String = "createNickname.identity.subtitle".localized
    private(set) var details: String = "createNickname.identity.details".localized
    private(set) var button: String = "createNickname.identity.button".localized
    private(set) var textFieldPlaceholder: String = "createNickname.identity.nicknameField.placeholder".localized
    private (set) var errorInvalid: ViewError = ViewError.invalidIdentityName
}

// MARK: -
// MARK: Presenter
protocol CreateNicknamePresenterProtocol: AnyObject {
	var view: CreateNicknameViewProtocol? { get set }
    func viewDidLoad()

    func closeButtonPressed()
    func next(nickname: String)
}

class CreateNicknamePresenter: CreateNicknamePresenterProtocol {

    weak var view: CreateNicknameViewProtocol?
    weak var delegate: CreateNicknamePresenterDelegate?

    private let viewModel = CreateNicknameViewModel()
    private var cancellables = [AnyCancellable]()

    private var defaultName: String?
    private var properties: CreateNicknameProperties

    init(withDefaultName name: String? = nil, delegate: CreateNicknamePresenterDelegate, properties: CreateNicknameProperties) {
        self.delegate = delegate
        self.defaultName = name
        self.properties = properties
    }

    func viewDidLoad() {
        view?.setNickname(defaultName ?? "")
        view?.setProperties(properties)

        view?.namePublisher
            .compactMap { $0 }
            .assign(to: \.name, on: viewModel)
            .store(in: &cancellables)

        viewModel.$name
            .compactMap { $0 }
            .map { !ValidationProvider.validate(.nameLength($0)) }
            .assign(to: \.invalidLengthError, on: viewModel)
            .store(in: &cancellables)

        viewModel.$name
            .withPrevious()
            .map {
                guard
                    let previous = $0.previous,
                    let current = $0.current,
                    !ValidationProvider.validate(.nameLength(current))
                else {
                    return false
                }

                return current.count >= (previous?.count ?? 0)
            }
            .assign(to: \.shakeTextView, on: viewModel)
            .store(in: &cancellables)

        viewModel.$name
            .compactMap { $0 }
            .map { ValidationProvider.validate(.nameLength($0)) }
            .assign(to: \.enableCtaButton, on: viewModel)
            .store(in: &cancellables)

        view?.bind(to: viewModel)
    }

    func closeButtonPressed() {
        delegate?.createNicknamePresenterCancelled(self)
    }

    func next(nickname: String) {
        if nickname.isValidName() {
            delegate?.createNicknamePresenter(
                self,
                didCreateName: nickname,
                properties: properties
            )
        } else {
            view?.showRecoverableErrorAlert(
                properties.errorInvalid,
                recoverActionTitle: "ok".localized,
                hasCancel: false
            ) { [weak self] in
                self?.view?.showKeyboard()
            }
        }
    }
}
