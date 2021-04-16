//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

// MARK: View
protocol ___VARIABLE_productName:identifier___ViewProtocol: class {

}

class ___VARIABLE_productName:identifier___Factory {
    class func create(with presenter: ___VARIABLE_productName:identifier___Presenter) -> ___VARIABLE_productName:identifier___ViewController {
        ___VARIABLE_productName:identifier___ViewController.instantiate(fromStoryboard: <#T##String#>) {coder in
            return ___VARIABLE_productName:identifier___ViewController(coder: coder, presenter: presenter)
        }
    }
}

class ___VARIABLE_productName:identifier___ViewController: BaseViewController, ___VARIABLE_productName:identifier___ViewProtocol, Storyboarded {

	var presenter: ___VARIABLE_productName:identifier___PresenterProtocol

    init?(coder: NSCoder, presenter: ___VARIABLE_productName:identifier___PresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self
        presenter.viewDidLoad()
    }

}
