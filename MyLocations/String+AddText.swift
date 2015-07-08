//
//  String+AddText.swift
//  MyLocations
//
//  Created by Joel on 2015-07-07.
//  Copyright (c) 2015 Joel Rorseth. All rights reserved.
//

extension String {
    // Method is marked as mutating in order to allow modifying self
    mutating func addText(text: String?, withSeparator separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}