//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

//Add this to your coordinator:
//    func show___VARIABLE_productName:identifier___() {
//        let vc = ___VARIABLE_productName:identifier___Factory.create(with: ___VARIABLE_productName:identifier___Presenter(delegate: self))
//        navigationController.pushViewController(vc, animated: false)
//    }


// MARK: -
// MARK: Delegate
protocol ___VARIABLE_productName:identifier___PresenterDelegate: class {

}

// MARK: -
// MARK: Presenter
protocol ___VARIABLE_productName:identifier___PresenterProtocol: class {
	var view: ___VARIABLE_productName:identifier___ViewProtocol? { get set }
    func viewDidLoad()
}

class ___VARIABLE_productName:identifier___Presenter: ___VARIABLE_productName:identifier___PresenterProtocol {

    weak var view: ___VARIABLE_productName:identifier___ViewProtocol?
    weak var delegate: ___VARIABLE_productName:identifier___PresenterDelegate?

    init(delegate: ___VARIABLE_productName:identifier___PresenterDelegate? = nil) {
        self.delegate = delegate
    }

    func viewDidLoad() {

    }
}
