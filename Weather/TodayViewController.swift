//
//  TodayViewController.swift
//  Weather
//
//  Created by Ondřej Veselý on 19.06.15.
//  Copyright (c) 2015 find-it.cz spol. s r. o. All rights reserved.
//

import UIKit
import CZWeatherKit
import GooglePlacesAutocomplete

import CoreLocation

class TodayViewController: UIViewController, FetchCurrentWeatherConditionDelegate, CLLocationManagerDelegate {
    
    // MARK: - Properties

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherIconLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var rainAmountLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windSpeedDirection: UILabel!
    var gpaViewController:GooglePlacesAutocomplete?

    lazy var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var currentWeatherCondition: CZWeatherCurrentCondition?
    
    var settings: Settings? {
        return appDelegate.settings
    }
    
    // Location selected by User
    var selectedPlace: PlaceDetails?
    var selectedLocation: CLLocation?
    
    // Location by GPS
    var detectedLocation: CLLocation?
    var detectedCity: String?
    let locationManager = CLLocationManager()

    // Accuracy in meters - prevents frequent refreshing weather data
    var locationAccuracy: CLLocationAccuracy = 1000

    // MARK: - Actions
    
    @IBAction func searchCities(sender: AnyObject) {
        if let gpaViewController = gpaViewController {
            gpaViewController.navigationBar.barStyle = .Default
            gpaViewController.navigationBar.translucent = false
            gpaViewController.navigationBar.tintColor = UIColor.blueColor()
            presentViewController(gpaViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareSheet(sender: AnyObject){

        if let weatherSummary = weatherSummary()  {
            var activityItems: [AnyObject] = []
            let activityItem =  weatherSummary
            activityItems.append(activityItem)
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems:activityItems, applicationActivities: nil)
            
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
        else {
            var alert = UIAlertController(title: "Alert", message: "Weather is not available now", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - View Life Cycle

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        clearUserInterface()

        var location = CZWeatherLocation(fromLocation: settings?.selectedLocation?.location!)
        cityLabel.text = settings?.selectedLocation?.city
        
        appDelegate.weatherModel.fetchCurrentWeatherCondition(self, location: location)
        
        self.navigationController?.navigationBar.translucent = false

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Places Autocomplete
        gpaViewController = GooglePlacesAutocomplete(
                apiKey: GOOGLE_API_KEY,
                placeType: .Cities
        )

        self.navigationController?.navigationBar.translucent = false
        gpaViewController?.placeDelegate = self

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - User Interface
    
    func setupUserInterface() {
        if let currentWeatherCondition = currentWeatherCondition {
            
            // Weather Icon
            // font color: #FFBF22
            // using Climacons-Font
            // https://github.com/christiannaths/Climacons-Font
            weatherIconLabel.setAttributedString(text: WeatherModel.stringByClimacon(currentWeatherCondition.climacon), fontName: "Climacons-Font", fontSize: 116, fontColor: UIColor(hex: 0xffbf22))
            
            // Wind
            
            //  Represents wind direction in degrees.
            let windDirection = currentWeatherCondition.windDirection

            // Wind Direction
            windSpeedDirection.text = degToCompass(windDirection)
            
            // Wind Speed
            let windSpeed = currentWeatherCondition.windSpeed
            var windSpeedString = "-"
            if settings?.lengthUnit?.unitId == UnitId.Meter {
                let value = Int(round(windSpeed.kph))
                windSpeedString = "\(value) km/h"
            }
            else {
                let value = Int(round(windSpeed.mph))
                windSpeedString = "\(value) mph"
            }
            windSpeedLabel.text = windSpeedString
            
            // Temperature
            let temperature = currentWeatherCondition.temperature
            var temperatureString = "-"
            if settings?.temperatureUnit?.unitId == UnitId.Celsius {
                let value = Int(round(temperature.c))
                temperatureString = "\(value) ºC"
            }
            else {
                let value = Int(round(temperature.f))
                temperatureString = "\(value) ºF"
            }

            summaryLabel.text = "\(temperatureString) | \(currentWeatherCondition.summary)"

            // Pressure
            let pressure = currentWeatherCondition.pressure
            // The pressure in millibars.
            // 1 millibar [mbar] = 1 hectopascal [hPa]
            pressureLabel.text = "\(pressure.mb) hPa"

            // Humidity
            let humidity = currentWeatherCondition.humidity
            humidityLabel.text = "\(humidity) %"
            
            // Rain
            rainAmountLabel.text = "N/A"
        }
        else {
            clearUserInterface()
        }
    }

    func clearUserInterface() {
        weatherIconLabel.text = ""
        windSpeedDirection.text = ""
        windSpeedLabel.text = ""
        summaryLabel.text = ""
        pressureLabel.text = ""
        humidityLabel.text = ""
        cityLabel.text = ""
        rainAmountLabel.text = ""
    }

    func fetchCurrentWeatherConditionDone(currentWeatherCondition: CZWeatherCurrentCondition) {
        self.currentWeatherCondition = currentWeatherCondition
        setupUserInterface()
    }
    
    // MARK: - Location
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var runReverseGeocoder = false
        if let detectedLocation = locations.last as? CLLocation {

            if self.detectedLocation == nil {
                self.detectedLocation = detectedLocation
                runReverseGeocoder = true
            }
            else {
                let distance = detectedLocation.distanceFromLocation(self.detectedLocation!)
                // distance in meters
                if distance > 500 {
                    runReverseGeocoder = true

                    self.detectedLocation = detectedLocation
                } else {
                }
            }
        }
        if detectedCity == nil {
            runReverseGeocoder = true
        }
        
        if runReverseGeocoder {
            CLGeocoder().reverseGeocodeLocation(self.detectedLocation, completionHandler: {(placemarks, error) -> Void in
                if (error != nil) {
//                    println("Reverse geocoder failed with error \(error.localizedDescription)")
                    return
                }
                
                if placemarks.count > 0 {
                    if let placemark = placemarks[0] as? CLPlacemark {
                        
                        let city = placemark.addressDictionary[kABPersonAddressCityKey] as? String
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if city != nil && self.detectedLocation != nil {
                                let gpsLocation = Location(city: city!, location: self.detectedLocation!)
                                self.appDelegate.settings?.gpsLocation = gpsLocation
                            }
                            self.detectedCity = city
                            self.updateWeatherByCurrentLocation()
                        })
                    }
                } else {
//                    println("Problem with the data received from geocoder")
                }
            })
        }
        
    }
    
    func updateWeatherByCurrentLocation() {
        var location = CZWeatherLocation(fromLocation: self.detectedLocation)
        clearUserInterface()
        cityLabel.text = self.detectedCity
        appDelegate.weatherModel.fetchCurrentWeatherCondition(self, location: location)
    }

    // MARK: - String
    
    private func weatherSummary() -> String? {
        if let currentWeatherCondition = currentWeatherCondition {
            let temperature = currentWeatherCondition.temperature
            var temperatureString = "-"
            if settings?.temperatureUnit?.unitId == UnitId.Celsius {
                let value = Int(round(temperature.c))
                temperatureString = "\(value) ºC"
            }
            else {
                let value = Int(round(temperature.f))
                temperatureString = "\(value) ºF"
            }
            let city = cityLabel.text ?? detectedCity ?? settings?.selectedLocation?.city ?? "-"
            return "Temperature in \(city) is \(temperatureString). Weather is  \(currentWeatherCondition.summary)"
        }
        return nil
    }
    
    func degToCompass(degrees: Float) -> String {
        var val = floor((degrees / 22.5) + 0.5)
        var arr = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
        let index:Int = Int(val % 16)
        return arr[index]
    }

}

// MARK: - GooglePlacesAutocompleteDelegate

extension TodayViewController: GooglePlacesAutocompleteDelegate {
    func placeSelected(place: Place) {
//        println(place.description)
        
        place.getDetails { details in
            //println(details)
            self.selectedPlace = details
            if self.selectedPlace != nil {
                self.selectedLocation = CLLocation(latitude: self.selectedPlace!.latitude, longitude: self.selectedPlace!.longitude)
                
                var location = CZWeatherLocation(fromLocation: self.selectedLocation)
                let  selectedLocation = Location(city: details.name, location: self.selectedLocation!)
                self.settings?.selectedLocation = selectedLocation
                self.appDelegate.saveSettings()
                self.appDelegate.weatherModel.fetchCurrentWeatherCondition(self, location: location)
                self.cityLabel.text = details.name
            }
            
        }
        dismissViewControllerAnimated(true, completion: nil)

    }
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


