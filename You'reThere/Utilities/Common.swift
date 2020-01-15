//
//  Common.swift
//  You'reThere
//
//  Created by SINCY on 13/12/19.
//  Copyright © 2019 SINCY. All rights reserved.
//

import UIKit
import Foundation

struct Constants {
    static let savedAlerts = "savedAlerts"
    static let alertCellIdentifier = "alertCell"
    static let unsupportedDevice = "Geofencing is not supported on this device! Hence, You're There will not work on your device"
    static let locationAccessErrorMsg = """
    Your geo alert is saved but will only be activated once you grant
    You're There permission to access the device location.
    """
    static let allDays = ["S", "M", "T", "W", "T", "F", "S"]
    static let daySelectorCellId = "dayCell"
    static let appColor = UIColor(red: 239, green: 70, blue: 34, alpha: 1)
}

extension UIViewController {
  func showAlert(withTitle title: String?, message: String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
    
    func showGeoAlertError(withGeoError error: GeoAlertError) {
        var message: String?
        switch error {
        case .deviceNotSupported:
            message = Constants.unsupportedDevice
        case .locationNotAccessable:
            message = Constants.locationAccessErrorMsg
        }
        showAlert(withTitle: "Warning", message: message)
    }
    
    func keyboardHeight(notification: Notification) -> CGFloat {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            return keyboardSize.height
        }
        return 0
    }
}
