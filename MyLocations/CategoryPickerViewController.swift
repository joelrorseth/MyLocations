//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Joel on 2015-05-24.
//  Copyright (c) 2015 Joel Rorseth. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
    var selectedCategoryName = ""
    var selectedIndexPath = NSIndexPath()
    
    let categories = ["No Category", "Apple Store",
        "Bar", "Bookstore",
        "Club", "Grocery Store",
        "Historic Building", "House",
        "Icecream Vendor", "Landmark",
        "Park"]
    
    
    
    //**********************************************************************************************
    //************************************************************** MARK: - View Controller Methods
    //**********************************************************************************************
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
    
    
    //**********************************************************************************************
    //**************************************************************** MARK: - UITableViewDataSource
    //**********************************************************************************************
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        // If this is the already-chosen cell...
        if categoryName == selectedCategoryName {
            // Display the category already selected
            cell.accessoryType = .Checkmark
            selectedIndexPath = indexPath
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.blackColor()
        
        if let textLabel = cell.textLabel {
            textLabel.textColor = UIColor.whiteColor()
            textLabel.highlightedTextColor = textLabel.textColor
        }
        
        let selectionView = UIView(frame: CGRect.zeroRect)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selectionView
    }
    
    
    
    //**********************************************************************************************
    //**************************************************************** MARK: - UITableViewDataSource
    //**********************************************************************************************
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // If the user actually selected a new category, then...
        if indexPath.row != selectedIndexPath.row {
            // Check the cell user has selected
            if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                newCell.accessoryType = .Checkmark
            }
            // Uncheck the previously selected cell
            if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
                oldCell.accessoryType = .None
            }
            
            // Reset the selected cell
            selectedIndexPath = indexPath
        }
    }
}
