//
//  Settings.swift
//  Weather
//
//  Created by Ondřej Veselý on 21.06.15.
//  Copyright (c) 2015 find-it.cz spol. s r. o. All rights reserved.
//

import Foundation
import CoreLocation

class Settings: NSObject{
    
    // MARK: - Properties
    
    var lengthUnit: UnitProtocol?
    var temperatureUnit: UnitProtocol?

    private var locations:[Location] = []

    var selectedLocation: Location?
    var gpsLocation: Location?
    
    
    // MARK: - Initialization

    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        if let lengthUnit = aDecoder.decodeObjectForKey("lengthUnit") as? Int {
            if let unitId = UnitId(rawValue: lengthUnit) {
                self.lengthUnit = Units.searchUnitById(unitId, inUnits:  Units.lengthUnits())
            }
        }
        if let temperatureUnit = aDecoder.decodeObjectForKey("temperatureUnit") as? Int {
            if let unitId = UnitId(rawValue: temperatureUnit) {
                self.temperatureUnit = Units.searchUnitById(unitId, inUnits:  Units.temperatureUnits())
            }
        }
    }

    // MARK: - NSCoding

    func encodeWithCoder(aCoder: NSCoder) {
        if let selectedLocation = self.selectedLocation {
            aCoder.encodeObject(selectedLocation, forKey: "selectedLocation")
        }
        if let lengthUnit = self.lengthUnit {
            aCoder.encodeObject(lengthUnit.unitId.rawValue, forKey: "lengthUnit")
        }
        if let temperatureUnit = self.temperatureUnit {
            aCoder.encodeObject(temperatureUnit.unitId.rawValue, forKey: "temperatureUnit")
        }
        
    }

    // MARK: - 
    
    func setupTemperatureUnitsByRawValue(rawValue: Int) {
        if let unitId = UnitId(rawValue: rawValue) {
            self.temperatureUnit = Units.searchUnitById(unitId, inUnits:  Units.temperatureUnits())
        }
    }
    
    func setupLengthUnitByRawValue(rawValue: Int) {
        if let unitId = UnitId(rawValue: rawValue) {
            self.lengthUnit = Units.searchUnitById(unitId, inUnits:  Units.lengthUnits())
        }
    }
    
    func addLocation(location: Location) {
        locations.append(location)
    }
    
    func removeLocation(location: Location) {
        if let locationIndex = find(locations, location) {
            locations.removeAtIndex(locationIndex)
        }
    }
    
    var allLocation:[Location] {
        var locations:[Location] = [Location]()
        if let gpsLocation = gpsLocation {
            locations.append(gpsLocation)
        }
        
        locations += self.locations
        
        return locations
    }

}
