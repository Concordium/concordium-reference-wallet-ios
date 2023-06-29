//
//  ConcordiumApplication.swift
//  ConcordiumWallet
//
//  Created by Concordium on 19/02/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let didReceiveAppTimeout   = Notification.Name("didReceiveAppTimeout")
}

class ConcordiumApplication: UIApplication {
    // Auto logout after N minutes of inactivity.
    let timeoutInSeconds: TimeInterval = 5 * 60 // TODO: read from some config?
    var timeoutTimer: Timer?

    // Listen for any touch. If the screen receives a touch, the timer is reset.
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        if event.allTouches?.contains(where: { $0.phase == .began || $0.phase == .moved }) == true {
            resetIdleTimer()
        }
    }

    // Resent the timer because there was user interaction.
    func resetIdleTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = Timer.scheduledTimer(timeInterval: timeoutInSeconds,
                                            target: self,
                                            selector: #selector(idleTimerExceeded),
                                            userInfo: nil,
                                            repeats: false)
    }

    // Post didReceiveAppTimeout notification, listen to by the AppDelegate.
    @objc func idleTimerExceeded() {
        NotificationCenter.default.post(name: .didReceiveAppTimeout, object: nil)
    }
}
