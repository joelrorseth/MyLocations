//
//  Functions.swift
//  MyLocations
//
//  Created by Joel on 2015-05-31.
//  Copyright (c) 2015 Joel Rorseth. All rights reserved.
//

import Foundation
import Dispatch

// Global functions and properties declared here outside any class
// ************************************************************************************

func afterDelay(seconds: Double, closure: () -> ()) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}

let applicationDocumentsDirectory: String = {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
    return paths[0]
}()