//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Joel on 2015-05-18.
//  Copyright (c) 2015 Joel Rorseth. All rights reserved.
//

import UIKit
import CoreData

let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

//----------------------------------------------------------------------------------------------
// Define a global function for handling fatal core data errors
//----------------------------------------------------------------------------------------------
func fatalCoreDataError(error: NSError?) {
    if let error = error {
        println("*** Fatal Error: \(error), \(error.userInfo)")
    }
    NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: error)
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //----------------------------------------------------------------------------------------------
    // Here pass along managedObjectContext to other vc's
    //----------------------------------------------------------------------------------------------
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Get a reference to CurrentLocationViewController
        let tabBarController = window!.rootViewController as! UITabBarController
        
        if let tabBarViewControllers = tabBarController.viewControllers {
            
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            currentLocationViewController.managedObjectContext = managedObjectContext
            
            let navigationController = tabBarViewControllers[1] as! UINavigationController
            let locationsViewController = navigationController.viewControllers[0] as! LocationsViewController
            locationsViewController.managedObjectContext = managedObjectContext
            
            let mapViewController = tabBarViewControllers[2] as! MapViewController
            mapViewController.managedObjectContext = managedObjectContext
        }
        listenForFatalCoreDataNotifications() // Register notification handler with NSNotificationCenter
        return true
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: CORE DATA
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    lazy var managedObjectContext: NSManagedObjectContext = { // Create NSManagedObjectContext object
        // Find the url of the Core Data model we made
        if let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") {
            
            // Create object representing data model during runtime
            if let model = NSManagedObjectModel(contentsOfURL: modelURL) {
                
                // Create NSPersistentStoreCoordinator object in charge of SQLite db
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                let documentsDirectory = urls[0] as! NSURL
                let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
                //println(storeURL)
                
                // Add SQLite db to store coordinator
                var error: NSError?
                if let store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) {
                    // Create NSManagedObjectContext object and return it
                    let context = NSManagedObjectContext()
                    context.persistentStoreCoordinator = coordinator
                    return context
                } else {
                    println("Error adding persistent store at \(storeURL): \(error!)")
                }
            } else {
                println("Error initializing model from: \(modelURL)")
            }
        } else {
            println("Could not find data model in app bundle")
        }
        
        abort()
    }()
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func listenForFatalCoreDataNotifications() {
        // Tell NSNotificationCenter you want to be notified fail notification is posted
        NSNotificationCenter.defaultCenter().addObserverForName(MyManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            notification in
            
            // Create alert, then add action for OK button
            let alert = UIAlertController(title: "Internal Error", message: "There was a fatal error in the app and it cannot continue.\n\n"
                + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: .Alert)
            
            let action = UIAlertAction(title: "OK", style: .Default) { _ in
                let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data Error", userInfo: nil)
                exception.raise() // Raise an NSException istead of abort
            }
            
            alert.addAction(action)
            
            // Present the alert
            self.viewControllerForShowingAlert().presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    //----------------------------------------------------------------------------------------------
    // Helper method to find a view controller that is visible
    //----------------------------------------------------------------------------------------------
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }


}

