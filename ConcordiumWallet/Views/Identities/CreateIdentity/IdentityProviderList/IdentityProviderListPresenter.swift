//
//  IdentityProviderListPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 10/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine
import UIKit

class IdentityGeneralViewModel: Hashable {
    var id: Int
    var nickname: String
    var identityName: String

    var iconEncoded: String
    var expiresOn: String
    var privacyPolicyURL: String
    var url: String?

    init(
        id: Int,
        identityName: String,
        iconEncoded: String,
        privacyPolicyURL: String?,
        nickname: String? = nil,
        expiresOn: String? = nil,
        url: String?
    ) {
        self.id = id
        self.identityName = identityName
        self.nickname = nickname ?? ""
        self.iconEncoded = iconEncoded
        self.expiresOn = expiresOn ?? ""
        self.privacyPolicyURL = privacyPolicyURL ?? ""
        self.url = url ?? ""
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(identityName)
        hasher.combine(privacyPolicyURL)
        hasher.combine(iconEncoded)
        hasher.combine(expiresOn)
    }

    static func == (lhs: IdentityGeneralViewModel, rhs: IdentityGeneralViewModel) -> Bool {
        lhs.id == rhs.id &&
            lhs.identityName == rhs.identityName &&
            lhs.privacyPolicyURL == rhs.privacyPolicyURL &&
            lhs.iconEncoded == rhs.iconEncoded &&
            lhs.expiresOn == rhs.expiresOn &&
            lhs.url == rhs.url
    }
}

class IdentityProviderViewModel: IdentityGeneralViewModel {

    convenience init(ipInfo: IPInfoResponseElement) {
        let id = ipInfo.ipInfo.ipIdentity
        let name = ipInfo.ipInfo.ipDescription.name
        let encodedIcon = ipInfo.metadata.icon
        let url = ipInfo.ipInfo.ipDescription.url

        let privacyPolicyURL = "https://developer.concordium.software/extra/Terms-and-conditions-Mobile-Wallet.pdf"
        self.init(id: id, identityName: name, iconEncoded: encodedIcon, privacyPolicyURL: privacyPolicyURL, url: url)
    }
}

class IdentityProviderListViewModel {
    @Published var identityProviders = [IdentityProviderViewModel]()
}

// MARK: Presenter -
protocol IdentityProviderListPresenterProtocol: AnyObject {
    var view: IdentityProviderListViewProtocol? { get set }
    func viewDidLoad()
    func closeIdentityProviderList()
    func userSelected(identityProviderIndex: Int)
    func userSelectedIdentitiyProviderInfo(url: URL)
    func getIdentityName() -> String
}

protocol IdentitiyProviderListPresenterDelegate: AnyObject {
    func closeIdentityProviderList()
    func openIdentityProviderInfo(url: URL)
    func identityRequestURLGenerated(urlRequest: URLRequest, createdIdentity: IdentityCreation)
}

class IdentityProviderListPresenter {
    weak var view: IdentityProviderListViewProtocol?
    weak var delegate: (IdentitiyProviderListPresenterDelegate & RequestPasswordDelegate)?
    private var cancellables: [AnyCancellable] = []
    @Published var ipInfo: [IPInfoResponseElement]?

    private var dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider
    let service: IdentitiesService
    
    private var openingIDPDialog = false

    private let initialAccountName: String
    private let identityName: String
    private var viewModel = IdentityProviderListViewModel()

    init(dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider,
         delegate: (IdentitiyProviderListPresenterDelegate & RequestPasswordDelegate)? = nil,
         accountNickname: String,
         identityNickname: String) {
        self.initialAccountName = accountNickname
        self.identityName = identityNickname
        self.delegate = delegate
        self.dependencyProvider = dependencyProvider
        self.service = dependencyProvider.identitiesService()
    }

    func viewDidLoad() {
        view?.bind(to: viewModel)
        service.getIpInfo()
                .showLoadingIndicator(in: view)
                .mapError(ErrorMapper.toViewError)
                .sink(receiveError: { [weak self] (error: ViewError) in
                    self?.view?.showErrorAlert(error)
                }, receiveValue: { [weak self] (ipInfo: [IPInfoResponseElement]) in
                    self?.ipInfo = ipInfo
                    let ipInfoToViewModel = IdentityProviderViewModel.init(ipInfo:)
                    self?.viewModel.identityProviders = ipInfo.map(ipInfoToViewModel)
                })
                .store(in: &cancellables)
    }
}

extension IdentityProviderListPresenter: IdentityProviderListPresenterProtocol {
    func userSelectedIdentitiyProviderInfo(url: URL) {
        delegate?.openIdentityProviderInfo(url: url)
    }

    func closeIdentityProviderList() {
        self.delegate?.closeIdentityProviderList()
    }

    func getIdentityName() -> String {
        return self.identityName
    }
    
    func userSelected(identityProviderIndex: Int) {
        guard !openingIDPDialog else {
            return
        }
        openingIDPDialog = true
        PermissionHelper.requestAccess(for: .camera) { [weak self] permissionGranted in
            guard let self = self else { return }
            
            guard permissionGranted else {
                self.openingIDPDialog = false
                DispatchQueue.main.async {
                    self.view?.showRecoverableErrorAlert(
                        .cameraAccessDeniedError,
                        recoverActionTitle: "errorAlert.continueButton".localized,
                        hasCancel: true
                    ) {
                        SettingsHelper.openAppSettings()
                    }
                }
                return
            }
            
            guard let delegate = self.delegate else { fatalError("Missing delegate in class IdentityProviderListPresenter") }
            guard let ipInfoResponse = self.ipInfo?[identityProviderIndex] else {
                fatalError("""
                              Something is not wired up properly - user should not
                              have been able to select an identity provider if we do
                              not have an ipInfo object here
                           """)
            }
            
            let identityProvider = IdentityProviderDataTypeFactory.create(ipData: ipInfoResponse)
            
            self.createIDRequest(identityProvider: identityProvider, requestPassWordDelegate: delegate)
                .sink(receiveError: { [weak self] error in
                    self?.openingIDPDialog = false
                    if case ViewError.userCancelled = error { return }
                    self?.view?.showErrorAlert(error)
                }, receiveValue: { [weak self] (resourceRequest, identityCreation) in
                    guard let self = self else { return }
                    
                    let urlRequest = resourceRequest.request
                    self.delegate?.identityRequestURLGenerated(urlRequest: urlRequest!, createdIdentity: identityCreation)
                    self.openingIDPDialog = false
                })
                .store(in: &self.cancellables)
        }
    }
    
    private func createIDRequest(
        identityProvider: IdentityProviderDataType,
        requestPassWordDelegate: RequestPasswordDelegate
    ) -> AnyPublisher<(ResourceRequest, IdentityCreation), ViewError> {
        let wallet = self.dependencyProvider.mobileWallet()
        
        return self.service.getGlobal()
            .showLoadingIndicator(in: self.view)
            .flatMap { [unowned self] global in
                wallet.createIdRequestAndPrivateData(initialAccountName: self.initialAccountName,
                                                     identityName: self.identityName,
                                                     identityProvider: identityProvider,
                                                     global: global,
                                                     requestPasswordDelegate: requestPassWordDelegate)
            }
            .tryMap { [unowned self] (idObjectRequest, identityCreation) -> (ResourceRequest, IdentityCreation) in
                let callbackUri = ApiConstants.callbackUri(with: identityCreation.id)
                let identityObjectRequest = try self.service.createIdentityObjectRequest(
                    on: identityProvider.issuanceStartURL,
                    with: IDRequest(idObjectRequest: idObjectRequest, redirectURI: callbackUri)
                )
                return (identityObjectRequest, identityCreation)
            }
            .mapError(ErrorMapper.toViewError)
            .eraseToAnyPublisher()
    }
}
