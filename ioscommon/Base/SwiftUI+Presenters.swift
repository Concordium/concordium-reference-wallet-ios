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

protocol ViewModelHolder {
    associatedtype Event
    associatedtype ViewModel: BaseViewModel<Event>
    
    init(viewModel: ViewModel)
}

class BaseViewModel<Event>: ObservableObject, EventHandler {
    @Published var navigationTitle: String?
    
    let eventChannel = PassthroughSubject<Event, Never>()
}

class SwiftUIPresenter<Event, ViewModel: BaseViewModel<Event>> {
    private var cancellables = Set<AnyCancellable>()
    
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.viewModel.eventChannel.sink { [weak self] event in
            self?.receive(event: event)
        }.store(in: &cancellables)
    }
    
    func receive(event: ViewModel.Event) {}
    
    final func present<Content: View & ViewModelHolder>(_ viewType: Content.Type) -> UIViewController where Content.ViewModel == ViewModel {
        return HostingController<Content>(viewModel: viewModel)
    }
}

private class HostingController<Content: View & ViewModelHolder>: UIHostingController<Content> {
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: Content.ViewModel) {
        super.init(rootView: Content.init(viewModel: viewModel))
        
        setup(with: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Must call init(coder:viewModel:) instead")
    }
    
    init?(coder aDecoder: NSCoder, viewModel: Content.ViewModel) {
        super.init(coder: aDecoder, rootView: Content.init(viewModel: viewModel))
        
        setup(with: viewModel)
    }
    
    private func setup(with viewModel: Content.ViewModel) {
        viewModel.$navigationTitle.sink { [weak self] title in
            self?.title = title
        }.store(in: &cancellables)
    }
}
