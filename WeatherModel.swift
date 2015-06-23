//
//  WeatherModel.swift
//  Weather
//
//  Created by Ondřej Veselý on 20.06.15.
//  Copyright (c) 2015 find-it.cz spol. s r. o. All rights reserved.
//

import Foundation
import CZWeatherKit

@objc protocol FetchCurrentWeatherConditionDelegate {
    func fetchCurrentWeatherConditionDone(currentWeatherCondition: CZWeatherCurrentCondition)
    optional func fetchCurrentWeatherConditionError()

}

@objc protocol FetchDailyForecastDelegate {
    func fetchDailyForecastDone(dailyForecasts: [CZWeatherForecastCondition])
    optional func fetchDailyForecastError()
}

class WeatherModel {

    init(openWeatherAPIKey: String) {
        self.openWeatherAPIKey = openWeatherAPIKey
    }
    
    var openWeatherAPIKey: String

    var currentWeatherCondition: CZWeatherCurrentCondition?
    
    // MARK: - Remote Api
    
    func fetchForecast(delegate: FetchDailyForecastDelegate?, days: Int, location: CZWeatherLocation) {
        let request = CZOpenWeatherMapRequest.newDailyForecastRequestForDays(NSInteger(days))
        
        request.key = openWeatherAPIKey
        request.location = location
        request.sendWithCompletion { (data, error) -> Void in
            if let error = error {
                delegate?.fetchDailyForecastError?()
            }
            
            if let weather = data {
                if let x = weather.dailyForecasts as? [CZWeatherForecastCondition] {
                    delegate?.fetchDailyForecastDone(x)
                }
                
                for forecast in weather.dailyForecasts {
                    // dreams come true here
                    
                }
            }
        }
    }
    
    func fetchCurrentWeatherCondition(delegate: FetchCurrentWeatherConditionDelegate?, location: CZWeatherLocation) {

        // Setup weather api
        
        let request = CZOpenWeatherMapRequest.newCurrentRequest()

        request.key = openWeatherAPIKey
        request.location = location
        
        
        request.sendWithCompletion { (data, error) -> Void in
            if let error = error {
                delegate?.fetchCurrentWeatherConditionError?()
            }
            
            if let weather = data {
                if let current = weather.current {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.currentWeatherCondition = current
                        delegate?.fetchCurrentWeatherConditionDone(current)
                    })
                }
            }
        }
        
        
    }
}

extension WeatherModel {
    
    class func stringByClimacon(climacon: Climacon) -> String {
        // Weather Icon
        // font color: #FFBF22
        // using Climacons-Font
        // https://github.com/christiannaths/Climacons-Font
            
        return String(UnicodeScalar(Int(climacon.rawValue)))
    }
}
