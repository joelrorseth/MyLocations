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
    // Ideal place to customize object loaded from storyboard
    //----------------------------------------------------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.blackColor()
        descriptionLabel.textColor = UIColor.whiteColor()
        descriptionLabel.highlightedTextColor = descriptionLabel.textColor
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        let selectionView = UIView(frame: CGRect.zeroRect)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectionView
        
        // Render the photos as round thumbnails
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
        photoImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }
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
        return UIImage(named: "No Photo")!
    }
    
    //----------------------------------------------------------------------------------------------
    // Called right before cell is made visible
    //----------------------------------------------------------------------------------------------
    override func layoutSubviews() {
        super.layoutSubviews()
        if let sv = superview {
            descriptionLabel.frame.size.width = sv.frame.size.width - descriptionLabel.frame.origin.x - 10
            addressLabel.frame.size.width = sv.frame.size.width - addressLabel.frame.origin.x - 10
        }
    }
}
