//
//  BakerMetadataViewController.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 21/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit
import Combine

// MARK: View
protocol BakerMetadataViewProtocol: AnyObject {
    var metadataPublisher: AnyPublisher<String, Never> { get }
}

class BakerMetadataFactory {
    class func create(with presenter: BakerMetadataPresenterProtocol) -> BakerMetadataViewController {
        BakerMetadataViewController.instantiate(fromStoryboard: "Stake") {coder in
            return BakerMetadataViewController(coder: coder, presenter: presenter)
        }
    }
}

class BakerMetadataViewController: BaseViewController, BakerMetadataViewProtocol, Storyboarded {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var metadataTextField: UITextField!
    
    var metadataPublisher: AnyPublisher<String, Never> {
        return metadataTextField.textPublisher
            .eraseToAnyPublisher()
    }
    
	var presenter: BakerMetadataPresenterProtocol

    init?(coder: NSCoder, presenter: BakerMetadataPresenterProtocol) {
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

    @IBAction func pressedContinue(_ sender: UIButton) {
        presenter.pressedContinue()
    }
    
    @IBAction func pressedClose(_ sender: UIButton) {
        presenter.pressedClose()
    }
}
