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
    func createIdentityRequestCreated(_ request: IDPIdentityRequest, isNewIdentityAfterSettingUpTheWallet: Bool)
}

class SelectIdentityProviderPresenter: SwiftUIPresenter<SelectIdentityProviderViewModel> {
    private weak var delegate: SelectIdentityProviderPresenterDelegate?
    
    private let identititesService: SeedIdentitiesService
    private var ignoreInput = false
    private var isNewIdentityAfterSettingUpTheWallet: Bool
    
    init(
        identitiesService: SeedIdentitiesService,
        delegate: SelectIdentityProviderPresenterDelegate,
        isNewIdentityAfterSettingUpTheWallet: Bool = false
    ) {
        self.identititesService = identitiesService

        self.delegate = delegate
        
        self.isNewIdentityAfterSettingUpTheWallet = isNewIdentityAfterSettingUpTheWallet
        
        super.init(
            viewModel: .init(
                identityProviders: [], isNewIdentityAfterSettingUpTheWallet : isNewIdentityAfterSettingUpTheWallet
            )
        )
        
        viewModel.navigationTitle = isNewIdentityAfterSettingUpTheWallet ? "newidentities.seed.selectprovider.navigationtitle".localized : "identities.seed.selectprovider.navigationtitle".localized
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
//        guard !ignoreInput else {
//            return
//        }
        
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
            
            Task {
                do {
                    let request = try await self.identititesService.requestNextIdentity(
                        from: ipData,
                        requestPasswordDelegate: delegate
                    )
                    
                    delegate.createIdentityRequestCreated(request, isNewIdentityAfterSettingUpTheWallet: self.isNewIdentityAfterSettingUpTheWallet)
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
