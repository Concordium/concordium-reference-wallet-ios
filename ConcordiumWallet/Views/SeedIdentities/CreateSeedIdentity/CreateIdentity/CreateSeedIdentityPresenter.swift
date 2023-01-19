//
//  CreateSeedIdentityPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 05/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol CreateSeedIdentityPresenterDelegate: AnyObject {
    func pendingIdentityCreated(_ identity: IdentityDataType, isNewIdentityAfterSettingUpTheWallet: Bool)
    func createIdentityView(failedToLoad error: Error)
    func cancelCreateIdentity()
}

class CreateSeedIdentityPresenter: SwiftUIPresenter<CreateSeedIdentityViewModel> {
    private weak var delegate: CreateSeedIdentityPresenterDelegate?
    
    private let request: IDPIdentityRequest
    private let identitiesService: SeedIdentitiesService
    private var isNewIdentityAfterSettingUpTheWallet: Bool
    
    init(
        request: IDPIdentityRequest,
        identitiesService: SeedIdentitiesService,
        delegate: CreateSeedIdentityPresenterDelegate, isNewIdentityAfterSettingUpTheWallet: Bool = false
    ) {
        self.request = request
        self.identitiesService = identitiesService
        self.delegate = delegate
        self.isNewIdentityAfterSettingUpTheWallet = isNewIdentityAfterSettingUpTheWallet
        
        super.init(
            viewModel: .init(
                request: request.resourceRequest.request
            )
        )
    }
    
    override func receive(event: CreateSeedIdentityEvent) {
        switch event {
        case .failedToLoad(let error):
            delegate?.createIdentityView(failedToLoad: error)
        case .receivedCallback(let callback):
            handleCallback(callback)
        case .close:
            delegate?.cancelCreateIdentity()
        }
    }
    
    private func handleCallback(_ callback: String) {
        guard let url = URL(string: callback) else {
            return
        }
        
        if let (identityCreationId, pollUrl) = ApiConstants.parseCallbackUri(uri: url) {
            handleIdentitySubmitted(identityCreationId: identityCreationId, pollUrl: pollUrl)
        } else {
            handleErrorCallback(url: url)
        }
    }
    
    private func handleIdentitySubmitted(identityCreationId: String, pollUrl: String) {
        
        guard identityCreationId == request.id else {
            return
        }
        
        do {
            let identity = try identitiesService.createPendingIdentity(
                identityProvider: request.identityProvider,
                pollURL: pollUrl,
                index: request.index
            )
            
            delegate?.pendingIdentityCreated(identity, isNewIdentityAfterSettingUpTheWallet: isNewIdentityAfterSettingUpTheWallet)
        } catch {
            viewModel.alertPublisher.send(.error(.genericError(reason: error)))
        }
    }
    
    private func handleErrorCallback(url: URL) {
        guard let errorString = url.queryFragments?["error"]?.removingPercentEncoding else {
            return
        }
        
        do {
            let error = try IdentityProviderErrorWrapper(errorString)
            
            if error.error.code == "USER_CANCEL" {
                delegate?.cancelCreateIdentity()
            } else {
                let serverError = ViewError.simpleError(localizedReason: error.error.detail)
                delegate?.createIdentityView(failedToLoad: serverError)
            }
        } catch {
            viewModel.alertPublisher.send(.error(.genericError(reason: error)))
        }
    }
}
