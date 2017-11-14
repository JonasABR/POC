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
    
    func angle(to comparisonPoint: CGPoint) -> CGFloat {
        let originX = comparisonPoint.x - self.x
        let originY = comparisonPoint.y - self.y
        let bearingRadians = atan2f(Float(originY), Float(originX))
        var bearingDegrees = CGFloat(bearingRadians).degrees
        return bearingDegrees
    }
}

extension CGFloat {
    var degrees: CGFloat {
        return self * CGFloat(180.0 / Double.pi)
    }
}


extension UIImage{
    public func rotatedAndScale(angle: CGFloat, size: CGSize, scale: CGFloat) -> UIImage {
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat.pi
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
        let t = CGAffineTransform(rotationAngle: degreesToRadians(angle));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        
        // Rotate the image context
        bitmap?.rotate(by: degreesToRadians(angle))
        bitmap?.scaleBy(x: scale, y: (scale * -1))
        
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        
        bitmap?.draw(cgImage!, in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
