//
//  PasscodeSelectionViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 18/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

struct PasswordSelectionStateContent {
    let title: String
    let descriptiveText: String
    let cautionText: String
    let showPasswordButton: Bool
    let showContinueButton: Bool
    let showCloseButton: Bool
}

class EnterPasswordFactory {
    class func create(with presenter: EnterPasswordPresenterProtocol) -> EnterPasswordViewController {
        EnterPasswordViewController.instantiate(fromStoryboard: "Login") { coder in
            return EnterPasswordViewController(coder: coder, presenter: presenter)
        }
    }
}

// MARK: View -
protocol EnterPasswordViewProtocol: AnyObject {
    var pincodeDelegate: PasscodeFieldDelegate? { get set }
    func showKeyboard()
    func setState(_: PasswordSelectionState, newPasswordFieldDelegate: PasswordFieldDelegate & PasscodeFieldDelegate, animated: Bool, reverse: Bool)
    func setContinueButtonEnabled(_: Bool)
    func showError(_: String)
}

// MARK: Presenter -
protocol EnterPasswordPresenterProtocol: AnyObject {
    var view: EnterPasswordViewProtocol? { get set }
    func viewDidLoad()
    func viewDidAppear()
    func passwordEntered(password: String)
    func passwordButtonTapped()
    func backTapped()
    func closePasswordViewTapped()
}

extension EnterPasswordPresenterProtocol {
    func passwordButtonTapped() {
    }

    func backTapped() {
    }

    func closePasswordViewTapped() {
    }
}

enum PasswordSelectionState {
    case selectPasscode
    case reenterPasscode
    case selectPassword
    case reenterPassword
    case selectExportPassword
    case reenterExportPassword
    case requestExportPassword
    case loginWithPassword
    case loginWithPasscode
    case requestPassword
    case requestPasscode
}

class EnterPasswordViewController: BaseViewController, Storyboarded {
    let passwordSelectionStates: [PasswordSelectionState: PasswordSelectionStateContent] = [
        .selectPasscode: PasswordSelectionStateContent(title: "selectPassword.passcode.title".localized,
                descriptiveText: "selectPassword.passcode.descriptiveText".localized,
                cautionText: "selectPassword.cautionText".localized,
                showPasswordButton: true,
                showContinueButton: false,
                showCloseButton: false),
        .reenterPasscode: PasswordSelectionStateContent(title: "selectPassword.passcode2.title".localized,
                descriptiveText: "selectPassword.passcode2.descriptiveText".localized,
                cautionText: "selectPassword.cautionText".localized,
                showPasswordButton: true,
                showContinueButton: false,
                showCloseButton: false),
        .selectPassword: PasswordSelectionStateContent(title: "selectPassword.password.title".localized,
                descriptiveText: "selectPassword.password.descriptiveText".localized,
                cautionText: "selectPassword.cautionText".localized,
                showPasswordButton: false,
                showContinueButton: true,
                showCloseButton: false),
        .reenterPassword: PasswordSelectionStateContent(title: "selectPassword.password2.title".localized,
                descriptiveText: "selectPassword.password2.descriptiveText".localized,
                cautionText: "selectPassword.cautionText".localized,
                showPasswordButton: false,
                showContinueButton: true,
                showCloseButton: false),
        .selectExportPassword: PasswordSelectionStateContent(title: "selectExportPassword.password.title".localized,
                descriptiveText: "selectExportPassword.password.descriptiveText".localized,
                cautionText: "",
                showPasswordButton: false,
                showContinueButton: true,
                showCloseButton: true),
        .reenterExportPassword: PasswordSelectionStateContent(title: "selectExportPassword.password2.title".localized,
                descriptiveText: "selectExportPassword.password2.descriptiveText".localized,
                cautionText: "",
                showPasswordButton: false,
                showContinueButton: true,
                showCloseButton: true),
        .requestExportPassword: PasswordSelectionStateContent(title: "requestExportPassword.password.title".localized,
                descriptiveText: "requestExportPassword.password.descriptiveText".localized,
                cautionText: "",
                showPasswordButton: false,
                showContinueButton: true,
                showCloseButton: true),
        .loginWithPasscode: PasswordSelectionStateContent(title: "login.passcode.title".localized,
                descriptiveText: "",
                cautionText: "",
                showPasswordButton: false,
                showContinueButton: false,
                showCloseButton: false),
        .loginWithPassword: PasswordSelectionStateContent(title: "login.password.title".localized,
                descriptiveText: "",
                cautionText: "",
                showPasswordButton: false,
                showContinueButton: true,
                showCloseButton: false),
        .requestPasscode: PasswordSelectionStateContent(title: "login.passcode.title".localized,
                descriptiveText: "",
                cautionText: "",
                showPasswordButton: false,
                showContinueButton: false,
                showCloseButton: true),
        .requestPassword: PasswordSelectionStateContent(title: "login.password.title".localized,
                descriptiveText: "",
                cautionText: "",
                showPasswordButton: false,
                showContinueButton: true,
                showCloseButton: true)
    ]

    var presenter: EnterPasswordPresenterProtocol
    var pincodeDelegate: PasscodeFieldDelegate? {
        get {
            getPincodeViewController()?.delegate
        }
        set {
            getPincodeViewController()?.delegate = newValue
        }
    }

    @IBOutlet weak var descriptiveText: LoginInfoLabel!
    @IBOutlet weak var cautionText: LoginWarningLabel!
    @IBOutlet weak var passwordContainer: UIView!
    @IBOutlet weak var continueButtonButtomConstraint: NSLayoutConstraint!
    @IBOutlet weak var usePasswordButtonButtomConstraint: NSLayoutConstraint!
    @IBOutlet weak var usePasswordButton: StandardButton!
    @IBOutlet weak var continueButton: StandardButton!
    @IBOutlet weak var errorText: LoginInfoLabel!

    init?(coder: NSCoder, presenter: EnterPasswordPresenterProtocol) {
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

    override func keyboardWillShow(_ keyboardHeight: CGFloat) {
        super.keyboardWillShow(keyboardHeight)

        continueButtonButtomConstraint.constant = keyboardHeight
        usePasswordButtonButtomConstraint.constant = keyboardHeight
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }

    @IBAction func usePasswordButtonPressed(_ sender: Any) {
        presenter.passwordButtonTapped()
    }

    @IBAction func continueButtonPressed(_ sender: UIButton) {
        presenter.passwordEntered(password: getPasswordViewController()?.getPassword() ?? "")
    }

    private func changePasswordView(from originalVC: UIViewController, to newVC: UIViewController, animated: Bool = true, reverse: Bool = false) {
        var reverseFactor: CGFloat = 1
        if reverse {
            reverseFactor = -1
        }
        if animated {
            add(child: newVC, inside: passwordContainer)
            newVC.view.setXPosition(reverseFactor * newVC.view.frame.size.width)

            UIView.animate(withDuration: 0.5, animations: {
                originalVC.view.translateXPosition(reverseFactor * -originalVC.view.frame.size.width)
                newVC.view.setXPosition(0)
            }, completion: { _ in
                self.remove(child: originalVC)
            })
        } else {
            add(child: newVC, inside: passwordContainer)
            remove(child: originalVC)
        }
    }
}

extension EnterPasswordViewController: EnterPasswordViewProtocol {
    func showKeyboard() {
        getPincodeViewController()?.passwordTextField.becomeFirstResponder()
    }

    func setContinueButtonEnabled(_ enabled: Bool) {
        self.continueButton.isEnabled = enabled
    }

    func setState(_ state: PasswordSelectionState, newPasswordFieldDelegate: PasswordFieldDelegate & PasscodeFieldDelegate,
                  animated: Bool, reverse: Bool) {
        let content = self.passwordSelectionStates[state]
        updateUIElements(content: content, state: state)
        changePasswordFields(state: state, newPasswordFieldDelegate: newPasswordFieldDelegate, animated: animated, reverse: reverse)
    }

    private func updateUIElements(content: PasswordSelectionStateContent?, state: PasswordSelectionState) {
        self.title = content?.title
        self.descriptiveText.text = content?.descriptiveText
        self.cautionText.text = content?.cautionText
        self.continueButton.isHidden = !(content?.showContinueButton ?? false)
        self.usePasswordButton.isHidden = !(content?.showPasswordButton ?? false)
        if content?.showCloseButton ?? false { self.showCloseButton() }

        self.continueButton.isEnabled = false
        errorText.text = ""

        let showBackButton = state == .selectPassword || state == .reenterPassword || state == .reenterPasscode || state == .reenterExportPassword
        let backItem = UIBarButtonItem(image: UIImage(named: "back_arrow_icon")?.scaleTo(Sizes.backButtonSize), style: .plain,
                target: presenter, action: #selector(CreatePasswordPresenter.backTapped))
        backItem.tintColor = .whiteText

        navigationItem.leftBarButtonItem = showBackButton ? backItem : nil
    }

    func showCloseButton() {
        let closeIcon = UIImage(named: "close_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }

    @objc func closeButtonTapped() {
        presenter.closePasswordViewTapped()
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func changePasswordFields(state: PasswordSelectionState,
                                      newPasswordFieldDelegate: PasswordFieldDelegate & PasscodeFieldDelegate,
                                      animated: Bool,
                                      reverse: Bool) {
        switch state {
        case .selectPasscode:
            if let confirmPincodeVC = getPassphraseViewController() {
                let pincodeVC = PasscodeFieldViewController.instantiate(fromStoryboard: "Login")
                pincodeVC.delegate = newPasswordFieldDelegate
                changePasswordView(from: confirmPincodeVC, to: pincodeVC, animated: animated, reverse: reverse)
            }
        case .reenterPasscode:
            if let pincodeVC = getPassphraseViewController() {
                let confirmPincodeVC = PasscodeFieldViewController.instantiate(fromStoryboard: "Login")
                confirmPincodeVC.delegate = newPasswordFieldDelegate
                changePasswordView(from: pincodeVC, to: confirmPincodeVC)
            }
        case .selectPassword, .selectExportPassword:
            if let pincodeVC = getPassphraseViewController() {
                let passwordVC = PasswordFieldViewController.instantiate(fromStoryboard: "Login")
                passwordVC.delegate = newPasswordFieldDelegate
                changePasswordView(from: pincodeVC, to: passwordVC, animated: animated, reverse: reverse)
            }
        case .reenterPassword, .reenterExportPassword:
            if let passwordVC = getPassphraseViewController() {
                let confirmPasswordVC = PasswordFieldViewController.instantiate(fromStoryboard: "Login")
                confirmPasswordVC.delegate = newPasswordFieldDelegate
                changePasswordView(from: passwordVC, to: confirmPasswordVC)
            }
        case .loginWithPassword, .requestPassword, .requestExportPassword:
            if let passwordVC = getPasswordViewController() {
                passwordVC.clear()
            } else if let passcodeVC = getPincodeViewController() {
                let passwordVC = PasswordFieldViewController.instantiate(fromStoryboard: "Login")
                passwordVC.delegate = newPasswordFieldDelegate
                changePasswordView(from: passcodeVC, to: passwordVC, animated: animated, reverse: reverse)
            }
        case .loginWithPasscode, .requestPasscode:
            getPincodeViewController()?.clear()
        }
    }

    private func getPassphraseViewController() -> UIViewController? {
        getPincodeViewController() ?? getPasswordViewController()
    }

    private func getPincodeViewController() -> PasscodeFieldViewController? {
        children.last(where: { $0 is PasscodeFieldViewController }) as? PasscodeFieldViewController
    }

    private func getPasswordViewController() -> PasswordFieldViewController? {
        children.last(where: { $0 is PasswordFieldViewController }) as? PasswordFieldViewController
    }

    func showError(_ s: String) {
        errorText.text = s
    }
}

#if DEBUG
import RealmSwift

extension EnterPasswordViewController {
    func showResetButton() {
        let resetButton = UIBarButtonItem(title: "RESET", style: .plain, target: self, action: #selector(reset))
        resetButton.tintColor = .whiteText
        navigationItem.rightBarButtonItem = resetButton
    }

    @objc func reset() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.passwordType.rawValue)
        let keychain = KeychainWrapper()
        _ = keychain.deleteKeychainItem(withKey: KeychainKeys.password.rawValue)
        _ = keychain.deleteKeychainItem(withKey: KeychainKeys.loginPassword.rawValue)

        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("note"),
            realmURL.appendingPathExtension("management")
        ]
        for URL in realmURLs {
            do {
                try FileManager.default.removeItem(at: URL)
            } catch {
                // handle error
            }
        }
    }
}
#endif
