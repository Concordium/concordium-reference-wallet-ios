//
//  SelectIdentityProviderPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

protocol SelectIdentityProviderPresenterDelegate: RequestPasswordDelegate {
    func showIdentityProviderInfo(url: URL)
    func createIdentityRequestCreated(_ request: SeedIdentityRequest)
}

class SelectIdentityProviderPresenter: SwiftUIPresenter<SelectIdentityProviderViewModel> {
    private weak var delegate: SelectIdentityProviderPresenterDelegate?
    
    private let index: Int
    private let identititesService: IdentitiesService
    private let wallet: SeedMobileWalletProtocol
    private var ignoreInput = false
    
    init(
        index: Int,
        identitiesService: IdentitiesService,
        wallet: SeedMobileWalletProtocol,
        delegate: SelectIdentityProviderPresenterDelegate
    ) {
        self.index = index
        self.identititesService = identitiesService
        self.wallet = wallet
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
                identityProviders: []
            )
        )
        
        viewModel.navigationTitle = "identities.seed.selectprovider.navigationtitle".localized
        
        viewModel.isLoadingPublisher.send(true)
        identitiesService.getIpInfo()
            .first()
            .mapError(ErrorMapper.toViewError(error:))
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.viewModel.isLoadingPublisher.send(false)
                    if case let .failure(error) = completion {
                        self?.viewModel.alertPublisher.send(.error(error))
                    }
                },
                receiveValue: { [weak self] identityProviders in
                    self?.viewModel.identityProviders = identityProviders
                }
            )
            .store(in: &cancellables)
    }
    
    override func receive(event: SelectIdentityProviderEvent) {
        guard !ignoreInput else {
            return
        }
        
        switch event {
        case let .showInfo(url):
            delegate?.showIdentityProviderInfo(url: url)
        case let .selectIdentityProvider(identityProvider):
            selectIdentityProvider(identityProvider)
        }
    }
    
    private func selectIdentityProvider(_ identityProvider: IPInfoResponseElement) {
        ignoreInput = true
        PermissionHelper.requestAccess(for: .camera) { [weak self] permissionGranted in
            guard let self = self else { return }
            
            guard permissionGranted else {
                self.ignoreInput = false
                self.viewModel.alertPublisher.send(
                    .recoverableError(
                        .cameraAccessDeniedError,
                        recoverActionTitle: "errorAlert.continueButton".localized,
                        hasCancel: true
                    ) {
                        SettingsHelper.openAppSettings()
                    }
                )
                
                return
            }
            
            self.viewModel.isLoadingPublisher.send(true)
            self.createIDRequest(
                identityProvider: IdentityProviderDataTypeFactory.create(
                    ipData: identityProvider
                )
            )
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.viewModel.isLoadingPublisher.send(false)
                    self?.ignoreInput = false
                    switch completion {
                    case .failure(ViewError.userCancelled), .finished:
                        break
                    case let .failure(error):
                        self?.viewModel.alertPublisher.send(.error(error))
                    }
                },
                receiveValue: { [weak self] request in
                    self?.delegate?.createIdentityRequestCreated(request)
                }
            )
            .store(in: &self.cancellables)
        }
    }
    
    private func createIDRequest(identityProvider: IdentityProviderDataType) -> AnyPublisher<SeedIdentityRequest, ViewError> {
        guard let delegate = delegate else {
            return Empty(completeImmediately: true)
                .eraseToAnyPublisher()
        }

        return wallet.getSeed(withDelegate: delegate)
            .zip(identititesService.getGlobal())
            .flatMap { (seed, global) in
                self.wallet.createIDRequest(
                    for: identityProvider,
                    index: self.index,
                    globalValues: global,
                    seed: seed
                ).publisher
            }
            .tryMap { idRequest in
                let requestID = UUID().uuidString
                let webRequest = try self.identititesService
                    .createSeedIdentityObjectRequest(
                        on: identityProvider.issuanceStartURL,
                        with: .init(
                            idObjectRequest: idRequest.idObjectRequest,
                            redirectURI: ApiConstants.callbackUri(
                                with: requestID
                            )
                        )
                    )
                
                return SeedIdentityRequest(
                    id: requestID,
                    index: self.index,
                    identityProvider: identityProvider,
                    webRequest: webRequest
                )
            }
            .mapError(ErrorMapper.toViewError(error:))
            .eraseToAnyPublisher()
    }
    
}
