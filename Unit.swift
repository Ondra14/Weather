//
//  Unit.swift
//  Weather
//
//  Created by Ondřej Veselý on 21.06.15.
//  Copyright (c) 2015 find-it.cz spol. s r. o. All rights reserved.
//

import Foundation

class Unit: NSObject, UnitProtocol {
    var unitId: UnitId
    var name: String

    init(unit: UnitId, name: String) {
        self.unitId = unit
        self.name = name
    }

    func unitDescription() -> String {
        return name
    }
}

protocol UnitProtocol {
    var unitId: UnitId { get }
    func unitDescription() -> String
}