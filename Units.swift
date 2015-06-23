//
//  Units.swift
//  Weather
//
//  Created by Ondřej Veselý on 21.06.15.
//  Copyright (c) 2015 find-it.cz spol. s r. o. All rights reserved.
//

import Foundation

enum UnitId: Int {
    case Celsius
    case Fahrenheit
    case Meter
    case Feet
}

class Units {
    
    class func lengthUnits() -> [UnitProtocol] {
        return [
            Unit(unit: UnitId.Meter, name: "Meters"),
            Unit(unit: UnitId.Feet, name: "Feets")
            
        ]
    }

    class func temperatureUnits() -> [UnitProtocol] {
        return [
            Unit(unit: UnitId.Celsius, name: "Celsius"),
            Unit(unit: UnitId.Fahrenheit, name: "Fahrenheit")
        ]
    }
    
    class func searchUnitById(unitId: UnitId, inUnits units: [UnitProtocol]) -> UnitProtocol? {
        let units = units.filter({$0.unitId == unitId})
        if units.count >= 1 {
            return units[0]
        }
        return nil
    }
    
}