//
//  SwiftUI+Presenters.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI
import UIKit
import Combine

protocol EventHandler {
    associatedtype Event
    
    var eventChannel: PassthroughSubject<Event, Never> { get }
}

extension EventHandler {
    func send(_ event: Event) {
        eventChannel.send(event)
    }
}

@MainActor
class SwiftUIPresenter<ViewModel: PageModel & EventHandler> {
    var cancellables = Set<AnyCancellable>()
    
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.viewModel.eventChannel.sink { [weak self] event in
            self?.receive(event: event)
        }.store(in: &cancellables)
    }
    
    func receive(event: ViewModel.Event) {}
    
    final func present<Content: Page>(_ viewType: Content.Type) -> UIViewController where Content.ViewModel == ViewModel {
        let controller = HostingController(presenter: self, page: Content.init(viewModel: viewModel))
    
        return controller
    }
}

private class HostingController<ViewModel: PageModel & EventHandler, Content: Page>: UIHostingController<Content>, ShowAlert, Loadable {
    // HostingController keep a strong ref to the presenter as it would otherwise immediately deinit
    private let presenter: SwiftUIPresenter<ViewModel>
    private var cancellables = Set<AnyCancellable>()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(presenter: SwiftUIPresenter<ViewModel>, page: Content) {
        self.presenter = presenter
        
        super.init(rootView: page)
        
        setup()
    }
    
    private func setup() {
        presenter.viewModel.alertPublisher.sink { [weak self] alert in
            switch alert {
            case let .alert(options):
                self?.showAlert(with: options)
            case let .error(error):
                self?.showErrorAlert(error)
            case let .recoverableError(error, recoverActionTitle, hasCancel, completion):
                self?.showRecoverableErrorAlert(
                    error,
                    recoverActionTitle: recoverActionTitle,
                    hasCancel: hasCancel,
                    completion: completion
                )
            }
        }.store(in: &cancellables)
    }
}

extension UIViewController {
    func isPresenting<Content: Page>(page: Content.Type) -> Bool where Content.ViewModel: EventHandler {
        return self is HostingController<Content.ViewModel, Content>
    }
}
