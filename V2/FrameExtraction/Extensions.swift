//
//  Extensions.swift
//  FrameExtraction
//
//  Created by Jonas Simões on 08/11/17.
//  Copyright © 2017 bRo. All rights reserved.
//

import UIKit

extension String {
    func drawFlipped(in rect: CGRect, withAttributes attributes: [String: Any]) {
        guard let gc = UIGraphicsGetCurrentContext() else { return }
        gc.saveGState()
        defer { gc.restoreGState() }
        gc.translateBy(x: rect.origin.x, y: rect.origin.y + rect.size.height)
        gc.scaleBy(x: 1, y: -1)
        self.draw(in: CGRect(origin: .zero, size: rect.size), withAttributes: attributes)
    }
    
    func textToImage(inImage: UIImage, atPoint: CGPoint) -> UIImage? {
        
        // Setup the font specific variables
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica Bold", size: 28)!
        
        // Setup the image context using the passed image
        let scale = inImage.scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ] as [String : Any]
        
        // Put the image into a rectangle as large as the original image
        inImage.draw(in: CGRect.init(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        
        // Create a point within the space that is as bit as the image
        let rect = CGRect.init(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)
        
        // Draw the text into an image
        self.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage ?? nil
        
    }
}

extension CGPoint {
    func distance(to rhs: CGPoint) -> CGFloat {
        return hypot(self.x.distance(to: rhs.x), self.y.distance(to: rhs.y))
    }



}
