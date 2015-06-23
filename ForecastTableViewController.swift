//
//  ForecastTableViewController.swift
//  Weather
//
//  Created by Ondřej Veselý on 20.06.15.
//  Copyright (c) 2015 find-it.cz spol. s r. o. All rights reserved.
//

import UIKit
import CZWeatherKit

class ForecastTableViewController: UITableViewController, FetchDailyForecastDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var titleLabel: UINavigationItem!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var weatherForecastConditions: [CZWeatherForecastCondition]?

    var settings: Settings? {
        return appDelegate.settings
    }
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var location = CZWeatherLocation(fromLocation: settings?.selectedLocation?.location!)
        var city = settings?.selectedLocation?.city

        appDelegate.weatherModel.fetchForecast(self, days: 7, location: location)
        titleLabel?.title = city
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.translucent = false
        //self.title = "my Title"

        self.tableView.registerNib(UINib(nibName: "ForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return weatherForecastConditions?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        if let cell = cell as? ForecastTableViewCell {
            // Configure the cell...
            if let weatherForecastConditions = weatherForecastConditions {
                let weatherForecastCondition = weatherForecastConditions[indexPath.row]
                
                // Weather icon
                cell.iconLabel.setAttributedString(text: WeatherModel.stringByClimacon(weatherForecastCondition.climacon), fontName: "Climacons-Font", fontSize: 70, fontColor: UIColor(hex: 0xffbf22))

                // Date
                cell.dateLabel.setAttributedString(text: DateHelper.formatDate(weatherForecastCondition.date), fontName: "ProximaNova-Semibold", fontSize: 20, fontColor: UIColor.blackColor())
                
                // Summary
                cell.weatherLabel.setAttributedString(text: weatherForecastCondition.summary, fontName: "ProximaNova-Regular", fontSize: 18, fontColor: UIColor.blackColor())
                
                // High Temperature
                var temperatureString = ""
                if settings?.temperatureUnit?.unitId == UnitId.Celsius {
                    let temperature = Int(round(weatherForecastCondition.highTemperature.c))
//                    temperatureString = "\(temperature) ºC"
                    temperatureString = "\(temperature)º"
                }
                else {
                    let temperature = Int(round(weatherForecastCondition.highTemperature.f))
//                    temperatureString = "\(temperature) ºF"
                    temperatureString = "\(temperature)º"
                }
                cell.temperatureLabel.setAttributedString(text: temperatureString, fontName: "ProximaNova-Light", fontSize: 70, fontColor: UIColor(hex: 0x2a7afc))

            }
        }
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

    func fetchDailyForecastDone(dailyForecasts: [CZWeatherForecastCondition]) {
        weatherForecastConditions = dailyForecasts
        self.tableView.reloadData()
    }
}

private class DateHelper {
    class func formatDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        let dateFormat = NSDateFormatter.dateFormatFromTemplate("EEEE", options: 0, locale: NSLocale.currentLocale())
        formatter.dateFormat = dateFormat
        return formatter.stringFromDate(date)
    }
}

