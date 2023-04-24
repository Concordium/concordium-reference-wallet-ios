//
//  LoginCoordinatorTests.swift
//  ConcordiumWalletTests
//
//  Created by Milan Sawicki on 24/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import XCTest

@testable import Mock

class LoginCoordinatorTests: XCTestCase {
    
    var sut: LoginCoordinator!
    
    func test_start() {
        //given
        
        sut = .init(navigationController: .init(), parentCoordinator: <#T##LoginCoordinatorDelegate#>, dependencyProvider: <#T##LoginDependencyProvider#>)
        
    }
}
