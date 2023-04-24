//
//  BaseViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 30/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Combine

@MainActor
class PageViewModel<Event>: ObservableObject, PageModel, EventHandler {
    @Published var navigationTitle: String?
    
    let isLoadingPublisher = CurrentValueSubject<Bool, Never>(false)
    let alertPublisher = PassthroughSubject<PageAlert, Never>()
    
    let eventChannel = PassthroughSubject<Event, Never>()
}
