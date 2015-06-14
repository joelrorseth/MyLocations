//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Joel on 2015-05-21.
//  Copyright (c) 2015 Joel Rorseth. All rights reserved.
//

import UIKit
import CoreLocation
import Dispatch
import CoreData

class LocationDetailsViewController: UITableViewController {
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var descriptionText = ""
    var categoryName = "No Category"
    var managedObjectContext: NSManagedObjectContext!
    var date = NSDate()
    
    // Property observer
    var locationToEdit: Location? {
        didSet { // Performed when new value is put in var
            if let location = locationToEdit {
                self.descriptionText = location.locationDescription
                self.categoryName = location.category
                self.date = location.date
                self.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    
    // Define closure to create object AND set properties in one go
    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    
    
    //**********************************************************************************************
    //******************************************************************** MARK: - Interface Builder
    //**********************************************************************************************
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    @IBAction func done() {
        // Animate the Tagged symbol
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        
        // Only ask core data for a new object if you dont already have one
        var location: Location!
        if let temp = locationToEdit {
            hudView.text = "Updated"
        } else {
            hudView.text = "Tagged"
            // Create Location object, the core data way...
            // Ask NSEntityDescription class to insert new object for your entity into the managed object context.
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext) as! Location
        }
        
        // Set properties of location (core data obj)
        location.locationDescription = descriptionText
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        // 'Save the context' aka save to persistent storage!
        var error: NSError?
        if !managedObjectContext.save(&error) { // output param
            fatalCoreDataError(error)
            return
        }
        
        
        // Make the call to our free function after 0.6s
        afterDelay(0.6) { // Trailing closure syntax
            // Tell view controller to dismiss itself
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        // Find the view controller that sent the "EXIT' segue
        let controller = segue.sourceViewController as! CategoryPickerViewController
        
        // Read the selectedCategoryName property
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    
    
    //**********************************************************************************************
    //************************************************************** MARK: - View Controller Methods
    //**********************************************************************************************
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check whether locationToEdit is set
        if let location = locationToEdit {
            title = "Edit Location"
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = formatDate(date)
        
        // Implement gesture recognizer to dismiss keyboard from screen
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Change the frame size programatically here
        descriptionTextView.frame.size.width = view.frame.size.width - 30
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        
        // Dismiss keyboard
        descriptionTextView.resignFirstResponder()
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    
    
    //**********************************************************************************************
    //****************************************************************** MARK: - UITableViewDelegate
    //**********************************************************************************************
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // ***Description Cell***
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88
        }
        // ***Address Cell***
        else if indexPath.section == 2 && indexPath.row == 2 {
            // Change frame property to allow word wrapping to this width (set height to accom. text)
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 155, height: 10000)
            
            // Size label back to proper height
            addressLabel.sizeToFit()
            
            // Realign the detail label 15pts from right screen edge
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            
            // Return margin with 10 for top and bottom
            return addressLabel.frame.size.height + 20
        }
        // ***Other***
        else {
            return 44
        }
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        // Limit taps to just the first two sections
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    
    
    //**********************************************************************************************
    //*********************************************************************** MARK: - Helper Methods
    //**********************************************************************************************
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        return
            "\(placemark.subThoroughfare) \(placemark.thoroughfare), " +
            "\(placemark.locality), " +
            "\(placemark.administrativeArea) \(placemark.postalCode)," +
            "\(placemark.country)"
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
}


//**********************************************************************************************
//**************************************************************************** MARK: - Extension
//**********************************************************************************************
extension LocationDetailsViewController: UITextViewDelegate {
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        descriptionText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        return true
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func textViewDidEndEditing(textView: UITextView) {
        descriptionText = textView.text
    }
}