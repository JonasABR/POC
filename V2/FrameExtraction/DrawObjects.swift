//
//  DrawObjects.swift
//  FrameExtraction
//
//  Created by Jonas Simões on 08/11/17.
//  Copyright © 2017 bRo. All rights reserved.
//

import UIKit
import Vision

class DrawObjects: NSObject {
    func drawCardBounds(source:UIImage?, bounds: [CGPoint]) -> UIImage? {
        guard let image = source else {
            return nil
        }
        
        var points: [CGPoint] = []
        for item in bounds {
            let point = CGPoint(x: item.x * image.size.width, y: image.size.height - (item.y * image.size.height))
            points.append(point)
        }
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        let context = UIGraphicsGetCurrentContext()!
        context.setLineWidth(3.0)
        context.setStrokeColor(UIColor.green.cgColor)
        context.addLines(between: points)
        context.drawPath(using: CGPathDrawingMode.stroke)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    func drawOnImage(source: UIImage,
                                 boundingRect: CGRect,
                                 faceLandmarkRegions: [VNFaceLandmarkRegion2D],
                                 leftPupil: CGPoint,
                                 rightPupil: CGPoint,
                                 ratio: CGFloat) -> (UIImage, String) {
        UIGraphicsBeginImageContextWithOptions(source.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: source.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.colorBurn)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        let rectWidth = source.size.width * boundingRect.size.width
        let rectHeight = source.size.height * boundingRect.size.height
        
        //draw image
        let rect = CGRect(x: 0, y:0, width: source.size.width, height: source.size.height)
        context.draw(source.cgImage!, in: rect)
        
        //draw overlay
        let fillColor = UIColor.red
        fillColor.setStroke()
        context.setLineWidth(2.0)
        
        for faceLandmarkRegion in faceLandmarkRegions {
            var points: [CGPoint] = []
            for i in 0..<faceLandmarkRegion.pointCount {
                points.removeAll()
                let point = faceLandmarkRegion.normalizedPoints[i]
                let centerPoint = CGPoint(x: CGFloat(boundingRect.origin.x * source.size.width + point.x * rectWidth), y: CGFloat(boundingRect.origin.y * source.size.height + point.y * rectHeight))
                
                points.append(CGPoint(x: CGFloat(centerPoint.x - 1), y: CGFloat(centerPoint.y)))
                points.append(CGPoint(x: CGFloat(centerPoint.x + 1), y: CGFloat(centerPoint.y)))
                points.append(CGPoint(x: CGFloat(centerPoint.x), y: CGFloat(centerPoint.y - 1)))
                points.append(CGPoint(x: CGFloat(centerPoint.x), y: CGFloat(centerPoint.y + 1)))
                context.addLines(between: points)
            }
            context.drawPath(using: CGPathDrawingMode.stroke)
        }
        
        // For now, we are just drawing the line between the pupils
        var points: [CGPoint] = []
        points.removeAll()
        let leftPupilPoint = CGPoint(x: CGFloat(boundingRect.origin.x * source.size.width + leftPupil.x * rectWidth), y: CGFloat(boundingRect.origin.y * source.size.height + leftPupil.y * rectHeight))
        let rightPupilPoint = CGPoint(x: CGFloat(boundingRect.origin.x * source.size.width + rightPupil.x * rectWidth), y: CGFloat(boundingRect.origin.y * source.size.height + rightPupil.y * rectHeight))
        points.append(leftPupilPoint)
        points.append(rightPupilPoint)
        
        context.addLines(between: points)
        context.drawPath(using: CGPathDrawingMode.stroke)
        
        var pupilDistanceString = ""
        let pupilDistance = leftPupilPoint.distance(to: rightPupilPoint) * ratio
        // Range for pupil distance
        if (pupilDistance > 40 && pupilDistance < 81){
            pupilDistanceString = "\(pupilDistance.rounded()) mm"
            // TODO: This is being rendered mirrored, I have no idea why
            //pupilDistanceString.draw(at: leftPupilPoint, withAttributes: attrs)
            //pupilDistanceString.drawFlipped(in: CGRect.init(x: 50, y: 50, width: 100.0, height: 100.0), withAttributes: attrs)
            // Debug purposes
            print("PD: \(pupilDistanceString)")
        }
        
        let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return (coloredImg, pupilDistanceString)
    }

    func drawGlasses(personPicture image:UIImage, boundingRect: CGRect, face :VNFaceObservation) -> UIImage {

        let landmarks = face.landmarks
        let noseMinYPoints = landmarks?.noseCrest?.normalizedPoints.max(by: { (lhs, rhs) -> Bool in
            return lhs.y < rhs.y
        })

        let leftpupilPoint = landmarks?.leftPupil?.normalizedPoints.max(by: { (lhs, rhs) -> Bool in
            return lhs.y < rhs.y
        })
        
        let rightpupilPoint = landmarks?.rightPupil?.normalizedPoints.max(by: { (lhs, rhs) -> Bool in
            return lhs.y < rhs.y
        })
        
        let angle = ((leftpupilPoint?.angle(to: rightpupilPoint!))! * -1)
        let distance = (leftpupilPoint?.distance(to: rightpupilPoint!))!
        //print("Eye Distance: \(distance)")
        
        // TODO: Change the size of the frame if the face is closer or far from the camera
        let scaleFactor = 1.0
        
        let boundsRectOriginX = boundingRect.origin.x * image.size.width
        let boundsRectOriginY = boundingRect.origin.y * image.size.height
        let rectWidth = image.size.width * boundingRect.size.width
        let rectHeight = image.size.height * boundingRect.size.height


        let positionX = boundsRectOriginX + noseMinYPoints!.x * rectWidth
        let framePositionY = noseMinYPoints!.y * rectHeight + boundsRectOriginY - 10

        let leftEyeX = boundsRectOriginX + leftpupilPoint!.x * rectWidth
        let leftEyeY = leftpupilPoint!.y * rectHeight + boundsRectOriginY
        let rightEyeX = boundsRectOriginX + rightpupilPoint!.x * rectWidth
        let rightEyeY = rightpupilPoint!.y * rectHeight + boundsRectOriginY
        let distancePixels = hypot(leftEyeX.distance(to: rightEyeX), leftEyeY.distance(to: rightEyeY))
        print("Pixels Distancer \(distancePixels)")

        var t = CGAffineTransform(scaleX: 1, y: -1)
        t = t.translatedBy(x: 0, y: -image.size.height)
        let pointUIKit = CGPoint(x: positionX, y: framePositionY).applying(t)

        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        var glass = UIImage(named: "frameFront")!
        let glassSize = CGSize(width: 2.3 * distancePixels, height: distancePixels)
        glass = glass.rotatedAndScale(angle: angle, size: glassSize, scale: CGFloat(scaleFactor))
        glass.draw(in: CGRect(x: pointUIKit.x - (glass.size.width / 2) , y: pointUIKit.y - (glass.size.height / 2), width: glass.size.width, height: glass.size.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!

    }
    

    func drawFacePoints(source: UIImage,
                                    boundingRect: CGRect,
                                    faceLandmarkRegions: [VNFaceLandmarkRegion2D]) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(source.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: source.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.colorBurn)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        let rectWidth = source.size.width * boundingRect.size.width
        let rectHeight = source.size.height * boundingRect.size.height
        
        //draw image
        let rect = CGRect(x: 0, y:0, width: source.size.width, height: source.size.height)
        context.draw(source.cgImage!, in: rect)
        
        //draw overlay
        let fillColor = UIColor.red
        fillColor.setStroke()
        context.setLineWidth(2.0)
        
        for faceLandmarkRegion in faceLandmarkRegions {
            var points: [CGPoint] = []
            for i in 0..<faceLandmarkRegion.pointCount {
                points.removeAll()
                let point = faceLandmarkRegion.normalizedPoints[i]
                let centerPoint = CGPoint(x: CGFloat(boundingRect.origin.x * source.size.width + point.x * rectWidth), y: CGFloat(boundingRect.origin.y * source.size.height + point.y * rectHeight))
                points.append(CGPoint(x: CGFloat(centerPoint.x - 1), y: CGFloat(centerPoint.y)))
                points.append(CGPoint(x: CGFloat(centerPoint.x + 1), y: CGFloat(centerPoint.y)))
                points.append(CGPoint(x: CGFloat(centerPoint.x), y: CGFloat(centerPoint.y - 1)))
                points.append(CGPoint(x: CGFloat(centerPoint.x), y: CGFloat(centerPoint.y + 1)))
                context.addLines(between: points)
            }
            context.drawPath(using: CGPathDrawingMode.stroke)
        }
        
        let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return (coloredImg)
    }
}
