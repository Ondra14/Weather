//
//  AppDelegate.swift
//  Weather
//
//  Created by Ondřej Veselý on 19.06.15.
//  Copyright (c) 2015 find-it.cz spol. s r. o. All rights reserved.
//

import UIKit
import CoreLocation
import FBSDKLoginKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var weatherModel = WeatherModel(openWeatherAPIKey: OPEN_WEATHER_API_KEY)

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        var error: NSError?
        
        return FBSDKApplicationDelegate.sharedInstance()
            .application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()

        loadSettings()
        
        
    }
    
    func application(application: UIApplication, openURL url: NSURL,
        sourceApplication: String?, annotation: AnyObject?) -> Bool {
            
            return FBSDKApplicationDelegate.sharedInstance()
                .application(application, openURL: url,
                    sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    var settings: Settings?
    
    lazy var userDefaults = NSUserDefaults.standardUserDefaults()

    func defaultSettings() {
        settings = Settings()

        let locale = NSLocale.currentLocale()
        let isMetric = locale.objectForKey(NSLocaleUsesMetricSystem) as? Bool ?? true

        var defaultLocation:Location?
        if isMetric {
            settings!.lengthUnit = Units.searchUnitById(UnitId.Meter, inUnits:  Units.lengthUnits())
            settings!.temperatureUnit = Units.searchUnitById(UnitId.Celsius, inUnits:  Units.temperatureUnits())
        }
        else {
            settings!.lengthUnit = Units.searchUnitById(UnitId.Feet, inUnits:  Units.lengthUnits())
            settings!.temperatureUnit = Units.searchUnitById(UnitId.Fahrenheit, inUnits:  Units.temperatureUnits())
        }
    }

    func loadSettings() {
        if let data = userDefaults.objectForKey("settings") as? NSData {
            let unarc = NSKeyedUnarchiver(forReadingWithData: data)
            settings = unarc.decodeObjectForKey("root") as? Settings
        }
        else {
            defaultSettings()
        }
        
        fetchDataFromFirebase()
    }

    func saveSettings() {
        if let settings = settings {
            userDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(settings), forKey: "settings")
        }
        userDefaults.synchronize()
    }
    
     
    // MARK: - Firebase/Facebook
    
    func fetchDataFromFirebase() {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
            let ref = Firebase(url: FIREBASE_URL)
            ref.authWithOAuthProvider("facebook", token: accessToken,
                withCompletionBlock: { error, authData in
                    
                    let ref = Firebase(url: FIREBASE_URL + "/users/" + authData.uid)
                    
                    // Attach a closure to read the data at our posts reference
                    ref.observeEventType(.Value, withBlock: { snapshot in
                        if let userData = snapshot.value as? NSDictionary {
//                            println("\(__FUNCTION__) \(userData)")
                            if let settings = self.settings {
                                if let lengthUnit = (userData["lengthUnit"] as? String)?.toInt() {
                                    settings.setupLengthUnitByRawValue(lengthUnit)
                                }
                                if let temperatureUnit = (userData["temperatureUnit"] as? String)?.toInt() {
                                    settings.setupTemperatureUnitsByRawValue(temperatureUnit)
                                }
                            }
                            
                        }
                    }, withCancelBlock: { error in
                        println(error.description)
                })
            })
            
        }
        else
        {
            // fb is not ready
        }
    }
    
}

