//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Joel on 2015-05-18.
//  Copyright (c) 2015 Joel Rorseth. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?

    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    var timer: NSTimer?
    var managedObjectContext: NSManagedObjectContext!
    
    
    
    //**********************************************************************************************
    //******************************************************************** MARK: - Interface Builder
    //**********************************************************************************************
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    @IBAction func getLocation() {
        // Ask for permission to get location, also modify Info.plist
        let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        // Determine which actions the button will perform at different circumstances
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
        configureGetButton()
    }
    
    
    
    //**********************************************************************************************
    //************************************************************** MARK: - View Controller Methods
    //**********************************************************************************************
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
    }

    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Use prepareForSegue to pass data (label info) into next view controller
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.coordinate = self.location!.coordinate
            controller.placemark = self.placemark
            controller.managedObjectContext = managedObjectContext // Pass along to LocationDetailsVC
        }
    }
    
    
    
    //**********************************************************************************************
    //************************************************************ MARK: - CLLocationManagerDelegate
    //**********************************************************************************************
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("didFailWithError \(error)")
        
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        
        // Store a reference to the last error in an ivar
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let newLocation = locations.last as! CLLocation
        println("didUpdateLocations \(newLocation)")
        
        // If location was found over 5s ago...
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        // Set distance to a huge number so we can work with it regardless
        var distance = CLLocationDistance(DBL_MAX)
        
        // Calculate distance between new and old readings
        if let location = location {
            distance = newLocation.distanceFromLocation(location)
        }
        
        // Is the new reading more useful than the previous?
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            updateLabels()
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                println("*** We're done!")
                stopLocationManager()
                configureGetButton()
                
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            // Prepare for geocoding
            if !performingReverseGeocoding {
                println("*** Going to geocode")
                performingReverseGeocoding = true
                
                // Make the request
                geocoder.reverseGeocodeLocation(location, completionHandler: {placemarks, error in
                    println("*** Found placemarks: \(placemarks), error: \(error)")
                    self.lastGeocodingError = error
                    
                    // Determine if placemark was found or not...
                    if error == nil && !placemarks.isEmpty {
                        // Take the last location update for accuracy
                        self.placemark = placemarks.last as? CLPlacemark
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        } else if distance < 1.0 { // Here check is distances are getting really close...
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10 {
                println("*** Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
    
    
    
    
    //**********************************************************************************************
    //*********************************************************************** MARK: - Helper Methods
    //**********************************************************************************************
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func updateLabels() {
        if let location = self.location { // If location is found
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)   // Format String
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude) // Format String
            tagButton.hidden = false
            messageLabel.text = ""
            
            // Determine what to write in the addressLabel.text
            if let placemark = placemark {
                // Placemarks must be converted into strings
                addressLabel.text = stringFromPlacemark(placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
        } else { // If no location is found yet
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.hidden = true
            
            var statusMessage: String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            
            messageLabel.text = statusMessage
        }
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            // Send didTimeOut to self after 60s
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
        }
    }
    
    //----------------------------------------------------------------------------------------------
    //---------------------------------------------------------------------------------------------- 
    func stopLocationManager() {
        if updatingLocation {
            if let timer = timer {
                timer.invalidate()
            }
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", forState: .Normal)
        } else {
            getButton.setTitle("Get My Location", forState: .Normal)
        }
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var line1 = ""
        line1.addText(placemark.subThoroughfare)
        line1.addText(placemark.thoroughfare, withSeparator: " ")
        
        var line2 = ""
        line2.addText(placemark.locality)
        line2.addText(placemark.administrativeArea, withSeparator: " ")
        line2.addText(placemark.postalCode, withSeparator: " ")
        
        if line1.isEmpty {
            return line2 + "\n "
        } else {
            return line1 + "\n" + line2
        }    
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func didTimeOut() {
        println("*** Time out")
        
        if location == nil {
            stopLocationManager()
            
            // Define a custom error to set for lastLocationError
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            
            updateLabels()
            configureGetButton()
        }
    }
}