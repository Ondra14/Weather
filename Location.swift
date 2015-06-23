//
//  Location.swift
//  Weather
//
//  Created by Ondřej Veselý on 21.06.15.
//  Copyright (c) 2015 find-it.cz spol. s r. o. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject {
    
    init(city: String, location: CLLocation) {
        self.city = city
        self.location = location
    }
    
    var city: String
    var location: CLLocation?
    
    
    required init(coder aDecoder: NSCoder) {
        city = ""
        
        if let city = aDecoder.decodeObjectForKey("city") as? String {
            self.city = city
        }
        if let location = aDecoder.decodeObjectForKey("location") as? CLLocation {
            self.location = location
        }
        
    }
    
    // MARK: - NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(city, forKey: "city")
        aCoder.encodeObject(location, forKey: "location")
    }
}