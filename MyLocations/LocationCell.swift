//
//  LocationCell.swift
//  MyLocations
//
//  Created by Joel on 2015-06-10.
//  Copyright (c) 2015 Joel Rorseth. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func configureForLocation(location: Location) {
        
        // Configure description label
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        // Configure address label
        if let placemark = location.placemark {
            var text = ""
            text.addText(placemark.subThoroughfare)
            text.addText(placemark.thoroughfare, withSeparator: " ")
            text.addText(placemark.locality, withSeparator: ", ")
            addressLabel.text = text
        } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
        
        photoImageView.image = imageForLocation(location)
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    func imageForLocation(location: Location) -> UIImage {
        if location.hasPhoto {
            if let image = location.photoImage {
                // Return the corresponding image
                return image.resizedImageWithBounds(CGSize(width: 52, height: 52))
            }
        }
        // If none, return empty placeholder image
        return UIImage()
    }
}
