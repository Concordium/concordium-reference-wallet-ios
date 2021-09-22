//
//  AddMemoViewController.swift
//  Mock
//
//  Created by Kristiyan Dobrev on 22/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit
import Combine

class AddMemoFactory {
    class func create(with presenter: AddMemoPresenter) -> AddMemoViewController {
        AddMemoViewController.instantiate(fromStoryboard: "SendFund") { coder in
            return AddMemoViewController(coder: coder, presenter: presenter)
        }
    }
}

class AddMemoViewController: BaseViewController, AddMemoViewProtocol, Storyboarded {
   
    var presenter: AddMemoPresenterProtocol
    
    private var cancellables = [AnyCancellable]()

    @IBOutlet weak var placeholderLabel: UILabel!
//    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var addMemoButton: StandardButton!
    @IBOutlet weak var addMemoButtonBottomConstraint: NSLayoutConstraint!
    
    init?(coder: NSCoder, presenter: AddMemoPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.view = self
        addMemoButton.isEnabled = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        view.addGestureRecognizer(tapGesture)
        
        presenter.viewDidLoad()
    }
    
    func bind(to: AddMemoViewModel) {
        
    }
    
    @objc private func hideKeyboardOnTap(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    @IBAction private func addMemoTapped(_ sender: Any) {

    }
}
