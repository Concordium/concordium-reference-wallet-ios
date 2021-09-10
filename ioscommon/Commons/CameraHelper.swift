//
//  CameraHelper.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 10/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import AVFoundation
import UIKit

struct CameraHelper {
    static func isCameraAccessAllowed() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            return false
        case .authorized, .notDetermined:
            return true
        default:
            return false
        }
    }
}
