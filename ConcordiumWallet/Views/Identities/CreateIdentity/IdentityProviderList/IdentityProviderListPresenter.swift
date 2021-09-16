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

    init(id: Int, identityName: String, iconEncoded: String, privacyPolicyURL: String?, nickname: String? = nil, expiresOn: String? = nil) {
        self.id = id
        self.identityName = identityName
        self.nickname = nickname ?? ""
        self.iconEncoded = iconEncoded
        self.expiresOn = expiresOn ?? ""
        self.privacyPolicyURL = privacyPolicyURL ?? ""
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
            lhs.expiresOn == rhs.expiresOn
    }
}

class IdentityProviderViewModel: IdentityGeneralViewModel {
    convenience init(ipInfo: IPInfoResponseElement) {
        let id = ipInfo.ipInfo.ipIdentity
        let name = ipInfo.ipInfo.ipDescription.name
        let encodedIcon = ipInfo.metadata.icon

        let privacyPolicyURL = "https://developer.concordium.software/extra/Terms-and-conditions-Mobile-Wallet.pdf"
        self.init(id: id, identityName: name, iconEncoded: encodedIcon, privacyPolicyURL: privacyPolicyURL)
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
    func getIdentityName() -> String
}

protocol IdentitiyProviderListPresenterDelegate: AnyObject {
    func closeIdentityProviderList()
    func identityRequestURLGenerated(urlRequest: URLRequest, createdIdentity: IdentityDataType)
}

class IdentityProviderListPresenter {
    weak var view: IdentityProviderListViewProtocol?
    weak var delegate: (IdentitiyProviderListPresenterDelegate & RequestPasswordDelegate)?
    private var cancellables: [AnyCancellable] = []
    @Published var ipInfo: [IPInfoResponseElement]?

    private var dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider
    let service: IdentitiesService

    private var identity: IdentityDataType
    private var viewModel = IdentityProviderListViewModel()

    init(dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider,
         delegate: (IdentitiyProviderListPresenterDelegate & RequestPasswordDelegate)? = nil,
         identityNickname: String) {
        identity = IdentityDataTypeFactory.create()
        identity.nickname = identityNickname
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
    func closeIdentityProviderList() {
        self.delegate?.closeIdentityProviderList()
    }

    func getIdentityName() -> String {
        return self.identity.nickname
    }
    
    func userSelected(identityProviderIndex: Int) {
        PermissionHelper.requestAccess(for: .camera) { [weak self] permissionGranted in
            guard let self = self else { return }
            
            guard permissionGranted else {
                DispatchQueue.main.async {
                    self.view?.showRecoverableAlert(.cameraAccessDeniedError) { SettingsHelper.openAppSettings() }
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
            
            self.identity = self.identity.withUpdated(identityProvider: IdentityProviderDataTypeFactory.create(ipData: ipInfoResponse))
            
            let wallet = self.dependencyProvider.mobileWallet()
            
            self.service.getGlobal().flatMap { global in
                wallet.createIdRequestAndPrivateData(identity: self.identity, global: global, requestPasswordDelegate: delegate)
            }
            .tryMap { [unowned self] (idObjectRequest: IDObjectRequestWrapper) -> ResourceRequest in
                return try self.service.createIdentityObjectRequest(
                    on: self.identity.identityProvider!.issuanceStartURL,
                    with: IDRequest(idObjectRequest: idObjectRequest, redirectURI: ApiConstants.notabeneCallback)
                )
            }
            .mapError(ErrorMapper.toViewError)
            .sink(receiveError: { [weak self] error in
                if case ViewError.userCancelled = error { return }
                self?.view?.showErrorAlert(error)
                }, receiveValue: { [weak self] resourceRequest in
                    guard let self = self else { return }
                    let urlRequest = resourceRequest.request
                    self.delegate?.identityRequestURLGenerated(urlRequest: urlRequest!, createdIdentity: self.identity)
            })
                .store(in: &self.cancellables)
        }
    }
}
