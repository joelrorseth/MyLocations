//
//  Location.swift
//  MyLocations
//
//  Created by Joel on 2015-06-07.
//  Copyright (c) 2015 Joel Rorseth. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class Location: NSManagedObject {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var date: NSDate
    @NSManaged var locationDescription: String
    @NSManaged var category: String
    @NSManaged var placemark: CLPlacemark?

}
