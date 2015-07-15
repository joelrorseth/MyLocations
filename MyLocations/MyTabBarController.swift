//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Joel on 2015-07-08.
//  Copyright (c) 2015 Joel Rorseth. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // By returning nil, the tab bar controller will look at its OWN preferredStatusBarStyle method
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
    }
}
