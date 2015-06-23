//
//  SelectUnitTableViewController.swift
//  Weather
//
//  Created by Ondřej Veselý on 21.06.15.
//  Copyright (c) 2015 find-it.cz spol. s r. o. All rights reserved.
//

import UIKit

protocol SelectUnitTableViewControllerDelegate {
    func unitDidSelected(unit: UnitProtocol, field: String?)
}

class SelectUnitTableViewController: UITableViewController {
    
    // MARK: - Types
    
    enum SectionIndex: Int {
        case units = 0
    }
    
    // MARK: - Properties
    
    var delegate: SelectUnitTableViewControllerDelegate?
    var selectedUnit: UnitProtocol? {
        didSet {
            updateCheckmark()
        }
    }
    var field: String?
    
    var units: [UnitProtocol]?
    
    // MARK: - View Life Cycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUserInterface()
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
        return units?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        if let units = units {
            cell.textLabel?.text = units[indexPath.row].unitDescription()
        }

        return cell
    }
    
    // MARK: - Update User Interface
    
    func updateUserInterface() {
        updateCheckmark()
    }
    
    func updateCheckmark() {
        if units == nil {return}
        
        for row in 0..<units!.count {
            
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: SectionIndex.units.rawValue))
            let unit = units![row]
            
            if let selectedUnit = selectedUnit {
                if selectedUnit.unitId == unit.unitId {
                    cell?.accessoryType = .Checkmark
                }
                else {
                    cell?.accessoryType = .None
                }
            }
            else {
                cell?.accessoryType = .None
            }
        }
    }

    // MARK: - Navigation
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if let units = units {
            let selectedUnit = units[indexPath.row]
            delegate?.unitDidSelected(selectedUnit, field: field)
            navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
}
