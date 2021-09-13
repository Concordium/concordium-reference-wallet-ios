//
//  PermissionHelper.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 10/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import AVFoundation
import UIKit

struct PermissionHelper {
    
    enum Permission {
        case camera
    }
    
    static func requestAccess(for permission: Permission, completionHandler: @escaping (_ permissionGranted: Bool) -> Void) {
        switch permission {
        
        case .camera:
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                completionHandler(true)
            case .denied:
                completionHandler(false)
            case .restricted, .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    completionHandler(granted)
                }
            default:
                return
            }
        }
    }
}
