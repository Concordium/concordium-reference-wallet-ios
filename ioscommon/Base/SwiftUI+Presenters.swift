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
    associatedtype ViewModel
    
    var viewModel: ViewModel { get }
    
    init(viewModel: ViewModel)
}

class SwiftUIPresenter<ViewModel: EventHandler> {
    private var cancellables = Set<AnyCancellable>()
    
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.viewModel.eventChannel.sink { event in
            self.receive(event: event)
        }.store(in: &cancellables)
    }
    
    func receive(event: ViewModel.Event) {}
    
    final func present<Content: View & ViewModelHolder>(_ viewType: Content.Type) -> UIViewController where Content.ViewModel == ViewModel {
        let controller = UIHostingController(rootView: Content.init(viewModel: viewModel))
        
        controller.navigationItem.titleView
        
        return controller
    }
}
