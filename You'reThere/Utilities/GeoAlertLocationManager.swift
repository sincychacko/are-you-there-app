//
//  GeoAlertLocationManager.swift
//  You'reThere
//
//  Created by SINCY on 19/12/19.
//  Copyright © 2019 SINCY. All rights reserved.
//

import Foundation
import MapKit

let sharedLocationManager = CLLocationManager()

enum GeoAlertError: Error {
    case deviceNotSupported
    case locationNotAccessable
}

class GeoAlertLocationManager {
    
    static let shared = GeoAlertLocationManager()
    
    private func alertRegion(with geoAlert: GeoAlert) -> CLCircularRegion {
      let region = CLCircularRegion(center: geoAlert.geoCoordinate, radius: 1000, identifier: geoAlert.name)
      region.notifyOnEntry = true
        
      return region
    }
    
    func startMonitoring(geoAlert: GeoAlert) -> Result<Any, GeoAlertError> {
      if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
        return .failure(.deviceNotSupported)
      }
      
      if CLLocationManager.authorizationStatus() != .authorizedAlways {
        return .failure(.locationNotAccessable)
      }
      
      let fenceRegion = alertRegion(with: geoAlert)
        sharedLocationManager.startMonitoring(for: fenceRegion)
        return .success(true)
    }
    
    func stopMonitoring(geoAlert: GeoAlert) {
        for region in sharedLocationManager.monitoredRegions {
        guard let circularRegion = region as? CLCircularRegion,
            circularRegion.identifier == geoAlert.name else { continue }
            sharedLocationManager.stopMonitoring(for: circularRegion)
      }
    }
}
