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
    
    private let identititesService: SeedIdentitiesService
    private let wallet: SeedMobileWalletProtocol
    private var ignoreInput = false
    
    init(
        identitiesService: SeedIdentitiesService,
        wallet: SeedMobileWalletProtocol,
        delegate: SelectIdentityProviderPresenterDelegate
    ) {
        self.identititesService = identitiesService
        
        self.wallet = wallet
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
                identityProviders: []
            )
        )
        
        viewModel.navigationTitle = "identities.seed.selectprovider.navigationtitle".localized
        viewModel.showLoading()
        
        Task {
            do {
                let ipInfo = try await identitiesService.getIpInfo()
                
                self.viewModel.identityProviders = ipInfo
                self.viewModel.hideLoading()
            } catch {
                self.viewModel.hideLoading()
                self.viewModel.showAlert(.error(ErrorMapper.toViewError(error: error)))
            }
        }
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
    
    private func selectIdentityProvider(_ ipData: IPInfoResponseElement) {
        ignoreInput = true
        PermissionHelper.requestAccess(for: .camera) { [weak self] permissionGranted in
            guard let self = self else { return }
            guard let delegate = self.delegate else {
                self.ignoreInput = false
                return
            }
            
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
            
            self.viewModel.showLoading()
            
            let identityProvider = IdentityProviderDataTypeFactory.create(
                ipData: ipData
            )
            let index = self.identititesService.nextIdentityindex
            
            Task {
                do {
                    let (id, request) = try await self.identititesService.createSeedIdentityRequest(
                        identityProvider: identityProvider,
                        index: index,
                        requestPasswordDelegate: delegate
                    )
                    
                    delegate.createIdentityRequestCreated(
                        .init(
                            id: id,
                            index: index,
                            identityProvider: identityProvider,
                            webRequest: request
                        )
                    )
                } catch {
                    switch error {
                    case ViewError.userCancelled:
                        break
                    default:
                        self.viewModel.showAlert(.error(ErrorMapper.toViewError(error: error)))
                    }
                }
                self.viewModel.hideLoading()
            }
        }
    }
    
}
