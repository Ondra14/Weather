//
//  SettingsTableViewController.swift
//  Weather
//
//  Created by Ondřej Veselý on 21.06.15.
//  Copyright (c) 2015 find-it.cz spol. s r. o. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class SettingsTableViewController: UITableViewController, SelectUnitTableViewControllerDelegate {

    // MARK: - Types
    
    struct Seque {
        static let selectlengthUnit = "length"
        static let selectTemperatureUnit = "temperature"
    }
    
    // MARK: - Properties

    lazy var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var lengthUnitLabel: UILabel!
    
    @IBOutlet weak var temperatureUnitLabel: UILabel!
    
    var selectedLengthUnit: UnitProtocol?
    var selectedTemperatureUnit: UnitProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectedLengthUnit = appDelegate.settings?.lengthUnit
        selectedTemperatureUnit = appDelegate.settings?.temperatureUnit
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        updateUserInterface()
    }
    
    override func viewDidAppear(animated: Bool) {
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 50))
        headerView.backgroundColor = UIColor.whiteColor()
        
        var label: UILabel = UILabel()
        
        label.text = self.tableView(tableView, titleForHeaderInSection: section)?.uppercaseString
        label.textColor = UIColor(red: 81/255, green: 140/255, blue: 254/255, alpha: 1)
        label.font = UIFont(name: "ProximaNova-Bold", size: 20)
        label.backgroundColor = UIColor.clearColor()
        label.frame = CGRectMake(20, 0, 100, 50)
        headerView.addSubview(label)
        
//        let line = UIView(frame: CGRectMake(0, tableView.bounds.size.height - 2, 2, tableView.bounds.size.width))
        let line = UIView(frame: CGRectMake(0, 48, tableView.bounds.size.width, 2))
        
        //Divider
        let divider = UIImage(named: "Divider")
        var dividerView = UIImageView(image: divider)
        
        dividerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 1)
            
        line.addSubview(dividerView)
        
        line.backgroundColor = UIColor.clearColor()
        headerView.addSubview(line)
        return headerView
    }

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 50))
        footerView.backgroundColor = UIColor.whiteColor()

        let line = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 2))
        //Divider
        let divider = UIImage(named: "Divider")
        var dividerView = UIImageView(image: divider)
        
        dividerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 1)
        
        line.addSubview(dividerView)
        
        line.backgroundColor = UIColor.clearColor()
        footerView.addSubview(line)
        return footerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    
    // MARK: - Update User Interface
    
    func updateUserInterface() {
        // Temperature Unit
        temperatureUnitLabel?.text = selectedTemperatureUnit?.unitDescription() ?? "n/a"

        // Temperature Unit
        lengthUnitLabel?.text = selectedLengthUnit?.unitDescription() ?? "n/a"
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            var units:[NSObject: String] = [NSObject: String]()
            
            switch identifier {

            case Seque.selectlengthUnit:
                if let unitTableViewController = segue.destinationViewController as? SelectUnitTableViewController {
                    unitTableViewController.units = Units.lengthUnits()
                    unitTableViewController.selectedUnit = selectedLengthUnit
                    unitTableViewController.delegate = self
                    unitTableViewController.field = "lengthUnit"
                }

            case Seque.selectTemperatureUnit:
                if let unitTableViewController = segue.destinationViewController as? SelectUnitTableViewController {
                    unitTableViewController.units = Units.temperatureUnits()
                    unitTableViewController.selectedUnit = selectedTemperatureUnit
                    unitTableViewController.delegate = self
                    unitTableViewController.field = "TemperatureUnit"
                }
                
            default:
                break
            }
        
        }
    }

    // MARK: - SelectUnitTableViewControllerDelegate

    func unitDidSelected(unit: UnitProtocol, field: String?) {
        if let field = field {
            switch field {
            
            case "TemperatureUnit":
                selectedTemperatureUnit = unit
                appDelegate.settings?.temperatureUnit = unit
                appDelegate.saveSettings()
                saveDataToFirebase()
                
            case "lengthUnit":
                selectedLengthUnit = unit
                appDelegate.settings?.lengthUnit = unit
                appDelegate.saveSettings()
                saveDataToFirebase()
            
            default:
                break
            }
        }
    }
}

extension SettingsTableViewController {
    
    // MARK: - Firebase/Facebook
    
    func saveDataToFirebase() {
//        println("\(__FUNCTION__)")
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
            
            let ref = Firebase(url: FIREBASE_URL)
            
            ref.authWithOAuthProvider("facebook", token: accessToken,
                withCompletionBlock: { error, authData in
                    
                    if error != nil {
//                        println("Login failed. \(error)")
                    } else {
//                        println("Logged in! \(authData)")
                        let email = authData.providerData["email"] as? NSString as? String
                        
                        let lengthUnitId = String(self.appDelegate.settings?.lengthUnit?.unitId.rawValue ?? 0)
                        let temperatureUnitId = String(self.appDelegate.settings?.temperatureUnit?.unitId.rawValue ?? 0)
                        
                        let userData = [
                            "provider": authData.provider,
                            "email": authData.providerData["email"] as? NSString as? String,
                            "lengthUnit": lengthUnitId,
                            "temperatureUnit": temperatureUnitId
                        ]
                        
                        ref.childByAppendingPath("users")
                            .childByAppendingPath(authData.uid).setValue(userData)
                        
                    }
            })
            
        }
        else
        {
            loginFacebookConfirm()
            
        }
    }
    
    private func loginFacebookConfirm() {
        let alertController = UIAlertController(title: "Welcome", message: "Do You Want to Log In with Your Facebook?", preferredStyle:
            
            UIAlertControllerStyle.ActionSheet)
        let callAction = UIAlertAction(title: "Ok let me in", style: .Default, handler: {
            action in
            self.registerFacebook()
        })
        
        alertController.addAction(callAction)
        
        // Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        alertController.addAction(cancelAction)
        
        
        self.presentViewController(alertController, animated: true) {
        }
        
    }
    
    /// register user with Facebook
    private func registerFacebook() {
        
        let firebase = Firebase(url: FIREBASE_URL)
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"], handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
//                println("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
//                println("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
//                println("facebook accessToken: \(accessToken)")
            }
        })
    }
}
