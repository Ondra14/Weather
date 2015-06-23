//
//  LocationTableViewController.swift
//  Weather
//
//  Created by Ondřej Veselý on 21.06.15.
//  Copyright (c) 2015 find-it.cz spol. s r. o. All rights reserved.
//

import UIKit
import CZWeatherKit
import GooglePlacesAutocomplete

class LocationTableViewController: UITableViewController {
    
    @IBAction func done(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    var gpaViewController:GooglePlacesAutocomplete?
    
    lazy var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.leftBarButtonItem=nil
        self.navigationItem.hidesBackButton=true
        
        
        // Setup Places Autocomplete
        gpaViewController = GooglePlacesAutocomplete(
            apiKey: GOOGLE_API_KEY,
            placeType: .Cities
        )
        gpaViewController?.placeDelegate = self
        
        self.navigationController?.navigationBar.translucent = false
        self.tableView.registerNib(UINib(nibName: "ForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        addOverlayButton()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if let locations = self.appDelegate.settings?.allLocation {
            return locations.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        if let cell = cell as? ForecastTableViewCell {

            if let locations = self.appDelegate.settings?.allLocation {
                
                
                let location = locations[indexPath.row]

                
                cell.iconLabel.setAttributedString(text: WeatherModel.stringByClimacon(Climacon.Sun), fontName: "Climacons-Font", fontSize: 70, fontColor: UIColor(hex: 0xffbf22))
                
                // City
                cell.dateLabel.setAttributedString(text: location.city, fontName: "ProximaNova-Semibold", fontSize: 20, fontColor: UIColor.blackColor())

                // Summary
                cell.weatherLabel.setAttributedString(text: "Summary here", fontName: "ProximaNova-Regular", fontSize: 18, fontColor: UIColor.blackColor())
                
                // High Temperature
                var temperatureString = ""
                if appDelegate.settings?.temperatureUnit?.unitId == UnitId.Celsius {
                    let temperature = Int(round(0.0))
                    //                    temperatureString = "\(temperature) ºC"
                    temperatureString = "\(temperature)º"
                }
                else {
                    let temperature = Int(round(0.0))
                    //                    temperatureString = "\(temperature) ºF"
                    temperatureString = "\(temperature)º"
                }
                cell.temperatureLabel.setAttributedString(text: temperatureString, fontName: "ProximaNova-Light", fontSize:     70, fontColor: UIColor(hex: 0x2a7afc))
            }
        }

        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

    // MARK: - Navigation
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let locations = self.appDelegate.settings?.allLocation {
            let location = locations[indexPath.row]
            self.appDelegate.settings?.selectedLocation = location
        }
    }
    
    // MARK: - Editing

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var deleteAction = UITableViewRowAction(style: .Default, title: "x              ") { (action, indexPath) -> Void in
            
            self.tableView(self.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
        }
        deleteAction.backgroundColor = UIColor(red: 247/255, green: 136/255, blue: 77/255, alpha: 1)
        
        return [deleteAction]
        
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (editingStyle == .Delete) {
            if let locations = self.appDelegate.settings?.allLocation {
                let location = locations[indexPath.row]
                self.appDelegate.settings?.removeLocation(location)
            }
            tableView.reloadData()
        }
    }

    
    // MARK: - UserInterface

    // Floating Add Button
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let tableBounds = tableView.bounds
        
        var floatingButtonFrame = button?.frame
        let newY = originalOrigin + tableBounds.origin.y
        
        floatingButtonFrame!.origin.y = newY
        button?.frame = floatingButtonFrame!
        
    }
    
    var button: UIButton?
    
    var originalOrigin: CGFloat = 0
    
    func addOverlayButton() {
        let tableFrame = tableView.frame
        let size:CGFloat = 80
        originalOrigin = tableView.frame.size.height - 200
        button = UIButton.buttonWithType(.Custom) as? UIButton
        button?.frame = CGRectMake(CGRectGetMidX(tableFrame)-size/2, originalOrigin , size, size)

        button!.backgroundColor = UIColor(red: 81/255, green: 140/255, blue: 254/255, alpha: 1)
        button?.setTitle("+", forState: UIControlState.Normal)
        button?.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: 60)
        button?.layer.cornerRadius = size / 2
        button?.addTarget(self, action: "searchCities:", forControlEvents: .TouchUpInside)
        
        tableView.addSubview(button!)

    }
    
    @IBAction func searchCities(sender: AnyObject) {
        if let gpaViewController = gpaViewController {
            gpaViewController.navigationBar.barStyle = .Default
            gpaViewController.navigationBar.translucent = false
            gpaViewController.navigationBar.tintColor = UIColor.blueColor()
            presentViewController(gpaViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - GooglePlacesAutocompleteDelegate

extension LocationTableViewController: GooglePlacesAutocompleteDelegate {
    func placeSelected(place: Place) {
        
        place.getDetails { details in
            
            var location = Location(city: details.name, location: CLLocation(latitude: details.longitude, longitude: details.longitude))
            self.appDelegate.settings?.addLocation(location)
            
            self.appDelegate.settings?.selectedLocation = location
            self.appDelegate.saveSettings()
            self.tableView.reloadData()
            
        }
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

