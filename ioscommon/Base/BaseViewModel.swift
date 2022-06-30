//
//  BaseViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 30/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Combine

class BaseViewModel<Event>: ObservableObject, EventHandler, PageModel {
    @Published var navigationTitle: String?
    
    let eventChannel = PassthroughSubject<Event, Never>()
}
