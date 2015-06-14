//
//  HudView.swift
//  MyLocations
//
//  Created by Joel on 2015-05-27.
//  Copyright (c) 2015 Joel Rorseth. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""
    
    //----------------------------------------------------------------------------------------------
    // Use convenience constructor to init view here instead of letting the caller do it
    //----------------------------------------------------------------------------------------------
    class func hudInView(view: UIView, animated: Bool) -> HudView {
        // Init method inherited from UIView
        let hudView = HudView(frame: view.bounds)
        hudView.opaque = false
        
        view.addSubview(hudView)
        view.userInteractionEnabled = false
        
        hudView.showAnimated(animated)
        return hudView
    }
    
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    override func drawRect(rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
        
        // -------------------------------------------
        // Create the rounded dark box
        // -------------------------------------------
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        // -------------------------------------------
        // UIImage has failable init; init?
        // -------------------------------------------
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHeight / 8)
            
            // Draw checkmark onto the screen
            image.drawAtPoint(imagePoint)
        }
        
        // -------------------------------------------
        // Draw text onto screen
        // -------------------------------------------
        let attribs = [NSFontAttributeName: UIFont.systemFontOfSize(16.0), NSForegroundColorAttributeName: UIColor.whiteColor()] // Dict.
        let textSize = text.sizeWithAttributes(attribs)
        
        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4)
        
        text.drawAtPoint(textPoint, withAttributes: attribs)
    }
    
    //----------------------------------------------------------------------------------------------
    // UIView-based animation
    //----------------------------------------------------------------------------------------------
    func showAnimated(animated: Bool) {
        if animated {
            // Setup initial view state
            alpha = 0
            transform = CGAffineTransformMakeScale(1.3, 1.3)
            
            // Establish the animation in a closure that will be called later
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(0), animations: {
                self.alpha = 1
                self.transform = CGAffineTransformIdentity
            }, completion: nil)
            
            
//            UIView.animateWithDuration(0.3, animations: {
//                // Setup final / target state
//                self.alpha = 1
//                self.transform = CGAffineTransformIdentity // Restore scale to normal
//            })
        }
    }
}