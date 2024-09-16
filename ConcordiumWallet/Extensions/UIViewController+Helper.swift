//
//  UIViewController+Helper.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 4.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension UIViewController {
    // MARK: - Properties
    
    var topUnsafeAreaHeight: CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first {$0.isKeyWindow}
            print("\(String(describing: window?.safeAreaInsets.top))")
            return window?.safeAreaInsets.top ?? 0.0
        }
        
        return 0.0
    }
    
    var bottomUnsafeAreaHeight: CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first {$0.isKeyWindow}
            print("\(String(describing: window?.safeAreaInsets.bottom))")
            return window?.safeAreaInsets.bottom ?? 0.0
        }
        
        return 0.0
    }
    
    // MARK: - Class
    
    class func topMostController() -> UIViewController {
        var topController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        
        return topController!
    }
    
    // MARK: - Public
    
    func showInfoMessage(_ message: String) {
        showMessage(message, popController: false)
    }
    
    func showErrorMessage(_ message: String) {
        showMessage(message, popController: false)
    }
    
    func showInfoMessage(_ message: String, popController: Bool) {
        showMessage(message, popController: popController)
    }
    
    func showErrorMessage(_ message: String, popController: Bool) {
        showMessage(message, popController: popController)
    }
    
    func showInfoMessage(_ message: String, popToRootController: Bool) {
        showMessage(message, popToRootController: popToRootController)
    }
    
    func showErrorMessage(_ message: String, popToRootController: Bool) {
        showMessage(message, popController: popToRootController)
    }
    
    func showInfoMessage(_ message: String, dismissController: Bool) {
        showMessage(message, dismissController: dismissController)
    }
    
    func showActionSheetWithMessage(_ message: String, buttonText: String, style: UIAlertAction.Style) {
        let actionSheet = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmButton = UIAlertAction(title: buttonText, style: style) { (action) in
            if self.responds(to: Selector(("onActionSheetButton"))) {
                self.perform(Selector(("onActionSheetButton")))
            }
        }
        
        actionSheet.addAction(cancelButton)
        actionSheet.addAction(confirmButton)
        actionSheet.preferredAction = confirmButton
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentCamera(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate, animated: Bool) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch (authStatus) {
        case .denied:
            showAlert(title: "This feature requires camera access", message: "In iPhone settings, tap WeMoke and turn on Camera")
        case .authorized:
            presentImagePickerControllerWithSourceType(.camera, delegate: delegate, animated: animated)
            
        default:
        // Not determined fill fall here - after first use, when is't neither authorized, nor denied we try to use camera, because system will ask itself for camera permissions
            presentImagePickerControllerWithSourceType(.camera, delegate: delegate, animated: animated)
        }
    }
    
    func presentPhotoLibrary(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate, animated: Bool) {
        presentImagePickerControllerWithSourceType(.photoLibrary, delegate: delegate, animated: animated)
    }
    
    // Add and remove child view controller
    
    func add(toParrentViewController parentViewController: UIViewController, onView parentView: UIView, withFrame frame: CGRect, withAnimation animationOption: UIView.AnimationOptions) {
        
        parentViewController.addChild(self)
        view.frame = frame
        UIView.transition(with: parentView, duration: 0.5, options: animationOption) {
            parentView.addSubview(self.view)
        } completion: { (completed) in
            self.didMove(toParent: parentViewController)
        }
    }
    
    func remove(fromParentViewController parentViewController: UIViewController, fromView parentView: UIView, withAnimation animationOption: UIView.AnimationOptions) {
        
        guard parent != nil else { return }
        
        willMove(toParent: nil)
        UIView.transition(with: parentView, duration: 0.5, options: animationOption) {
            self.view.removeFromSuperview()
        } completion: { (completed) in
            self.removeFromParent()
        }
    }
    
    // MARK: - Phone Calls
    
    func makeCall(number: String) {
        if let url = URL(string: "tel://\(number)"),
            UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Private
    
    private func showMessage(_ message: String, popController: Bool)
    {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK", style: .cancel) { (action) in
            if popController {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showMessage(_ message: String, popToRootController: Bool)
    {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK", style: .cancel) { (action) in
            if popToRootController {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showMessage(_ message: String, dismissController: Bool)
    {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK", style: .cancel) { (action) in
            if dismissController {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentImagePickerControllerWithSourceType(_ sourceType: UIImagePickerController.SourceType, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate, animated: Bool) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = delegate
            imagePickerController.sourceType = sourceType
            present(imagePickerController, animated: animated, completion: nil)
        }
    }
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "Not Now", style: .cancel, handler: nil)
        alert.addAction(okAction)
        
        let settingsAction = UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            // Take the user to Settings app to possibly change permission.
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        // Finished opening URL
                    })
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
        })
        alert.addAction(settingsAction)
        
        present(alert, animated: true, completion: nil)
    }
}
