//
//  MapViewController.swift
//  MyLocations
//
//  Created by Joel on 2015-06-14.
//  Copyright (c) 2015 Joel Rorseth. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    var locations = [Location]()
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextObjectsDidChangeNotification,
                object: managedObjectContext,
                queue: NSOperationQueue.mainQueue())
                { notification in
                if self.isViewLoaded() {
                    self.updateLocations()
                }
            }
        }
    }
    
    
    //**********************************************************************************************
    //************************************************************** MARK: - View Controller Methods
    //**********************************************************************************************
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        
        if !locations.isEmpty {
            showLocations()
        }
    }
    
    
    //**********************************************************************************************
    //******************************************************************** MARK: - Interface Builder
    //**********************************************************************************************
    @IBOutlet weak var mapView: MKMapView!
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    @IBAction func showLocations() {
        let region = regionForAnnotations(locations)
        mapView.setRegion(region, animated: true)
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.managedObjectContext = managedObjectContext
            
            let button = sender as! UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
        }
    }
    
    
    
    //**********************************************************************************************
    //*********************************************************************** MARK: - Helper Methods
    //**********************************************************************************************
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func updateLocations() {
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        
        var error: NSError?
        let foundObjects = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        
        if foundObjects == nil {
            fatalCoreDataError(error)
            return
        }
        
        // Reset and add pins to map
        mapView.removeAnnotations(locations)
        locations = foundObjects as! [Location]
        mapView.addAnnotations(locations)
    }
    
    //----------------------------------------------------------------------------------------------
    // Calculate the optimal region for the mapView to zoom into
    //----------------------------------------------------------------------------------------------
    func regionForAnnotations(annotations: [MKAnnotation]) -> MKCoordinateRegion {
        var region: MKCoordinateRegion
        
        switch annotations.count {
            // No annotations
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
            
            // One annotation, center to it
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
            
            // 2 or more annotations
        default:
            // Calculate extent of their reach, then add padding
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            
            let extraSpace = 1.1
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        return mapView.regionThatFits(region)
    }
    
    //----------------------------------------------------------------------------------------------
    // Send button along so prepareForSegue can read its tag property
    //----------------------------------------------------------------------------------------------
    func showLocationDetails(sender: UIButton) {
        // Segue must be performed manually as we never connected it to any certain control
        performSegueWithIdentifier("EditLocation", sender: sender)
    }
}



//**********************************************************************************************
//******************************************************************** MARK: - MKMapViewDelegate
//**********************************************************************************************
extension MapViewController: MKMapViewDelegate {
    
    //----------------------------------------------------------------------------------------------
    // mapView(viewForAnnotation:) -- similar to cellForRowAtIndexPath
    //----------------------------------------------------------------------------------------------
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        // Type check annotation to make sure it is of type Location
        if annotation is Location {
            // Ask map view to reuse annotation view object
            let identifier = "Location"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView!
            
            // Create new annotation view if recycled one isnt found
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.enabled = true
                annotationView.canShowCallout = true
                annotationView.animatesDrop = false
                annotationView.pinColor = .Green
                annotationView.tintColor = UIColor(white: 0.0, alpha: 0.5)
                
                // Create DD button using target-action, hook up Touch Up Inside event with a method
                let rightButton = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
                rightButton.addTarget(self, action: Selector("showLocationDetails:"), forControlEvents: .TouchUpInside)
                annotationView.rightCalloutAccessoryView = rightButton
            } else {
                annotationView.annotation = annotation
            }
            
            // Obtain reference to DD button and set its tag to index of Location object in locations array
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = find(locations, annotation as! Location) {
                button.tag = index
            }
            
            return annotationView
        }
        return nil
    }
}



//**********************************************************************************************
//************************************************************** MARK: - UINavigationBarDelegate
//**********************************************************************************************
extension MapViewController: UINavigationBarDelegate {
    
    //----------------------------------------------------------------------------------------------
    // Tell navigation bar to extend under the status bar area
    //----------------------------------------------------------------------------------------------
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
        // Also assign map view controller as tab bar's delegate in storyboard
    }
    
}