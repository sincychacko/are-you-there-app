//
//  GeoAlert.swift
//  You'reThere
//
//  Created by SINCY on 12/12/19.
//  Copyright © 2019 SINCY. All rights reserved.
//

import Foundation
import CoreLocation

struct GeoAlert: Codable {
    
    enum RepeatMode: Int {
        case justOnce = 0
        case always = 1
    }
    
    enum CodingKeys: String, CodingKey {
      case latitude, longitude, name, repeatMode
    }
    
    var geoCoordinate: CLLocationCoordinate2D
    var name: String
    var repeatMode: RepeatMode
    var alertDate: Date?
    
    
    init(coordinate: CLLocationCoordinate2D, name: String, repeatMode: RepeatMode, date: Date? = nil) {
      geoCoordinate = coordinate
      self.name = name
      self.repeatMode = repeatMode
      self.alertDate = date
    }
    
    // MARK: Codable
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        geoCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
        name = try values.decode(String.self, forKey: .name)
        let rMode = try values.decode(Int.self, forKey: .repeatMode)
        self.repeatMode = RepeatMode(rawValue: rMode) ?? .justOnce
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(geoCoordinate.latitude, forKey: .latitude)
        try container.encode(geoCoordinate.longitude, forKey: .longitude)
        try container.encode(name, forKey: .name)
        try container.encode(repeatMode.rawValue, forKey: .repeatMode)
    }
}
