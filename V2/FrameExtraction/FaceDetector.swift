//
//  FaceDetector.swift
//  FaceVision
//
//  Created by Avenue Code on 31/10/17
//

import UIKit
import Vision

class FaceDetector {
    
    func distance(from lhs: CGPoint, to rhs: CGPoint) -> CGFloat {
        return hypot(lhs.x.distance(to: rhs.x), lhs.y.distance(to: rhs.y))
    }
    
    func getPupil(eyePoint eye: VNFaceLandmarkRegion2D) -> CGPoint {
        let leftEyePoints = eye.normalizedPoints
        var minimumXLeft : CGFloat = 1000
        var maximumXLeft : CGFloat = 0
        var minimumYLeft : CGFloat = 1000
        var maximumYLeft : CGFloat = 0
        for point in leftEyePoints{
            if (point.x < minimumXLeft){
                minimumXLeft = point.x
            }
            if (point.x > maximumXLeft){
                maximumXLeft = point.x
            }
            if (point.y < minimumYLeft){
                minimumYLeft = point.y
            }
            if (point.y > maximumYLeft){
                maximumYLeft = point.y
            }
        }
        
        let middleXLeft = (minimumXLeft + maximumXLeft)  / 2
        let middleYLeft = (minimumYLeft + maximumYLeft)  / 2

        return CGPoint(x: middleXLeft, y: middleYLeft)
    }


    open func highlightFaces(for source: UIImage, cardSize: CGFloat, complete: @escaping (UIImage) -> Void) {
        var resultImage = source
        let detectFaceRequest = VNDetectFaceLandmarksRequest { (request, error) in
            if error == nil {
                if let results = request.results as? [VNFaceObservation] {
                    
                    for faceObservation in results {
                        guard let landmarks = faceObservation.landmarks else {
                            continue
                        }
                        let boundingRect = faceObservation.boundingBox
                      
                        var landmarkRegions: [VNFaceLandmarkRegion2D] = []

                        /* All the possible detections
                                               
                       if let faceContour = landmarks.faceContour {
                            landmarkRegions.append(faceContour)
                        }
                        
                         if let leftEye = landmarkRegions.leftEye {
                             landmarkRegions.append(leftEye)
                         }
                         if let rightEye = rightEye {
                         landmarkRegions.append(rightEye)
                         }

                        if let nose = landmarks.nose {
                            landmarkRegions.append(nose)
                        }
                        if let noseCrest = landmarks.noseCrest {
                            landmarkRegions.append(noseCrest)
                        }
                        if let medianLine = landmarks.medianLine {
                            landmarkRegions.append(medianLine)
                        }
                        if let outerLips = landmarks.outerLips {
                            landmarkRegions.append(outerLips)
                        }
                        
                         if let leftEyebrow = landmarks.leftEyebrow {
                         landmarkRegions.append(leftEyebrow)
                         }
                         if let rightEyebrow = landmarks.rightEyebrow {
                         landmarkRegions.append(rightEyebrow)
                         }
                        
                         
                         if let innerLips = landmarks.innerLips {
                         landmarkRegions.append(innerLips)
                         }
                         if let leftPupil = landmarks.leftPupil {
                         landmarkRegions.append(leftPupil)
                         }
                         if let rightPupil = landmarks.rightPupil {
                         landmarkRegions.append(rightPupil)
                         }*/
                        
                        let pixelMmRatio : CGFloat
                        pixelMmRatio = 86 / cardSize
                        resultImage = self.drawOnImage(source: resultImage,
                                                  boundingRect: boundingRect,
                                                  faceLandmarkRegions: landmarkRegions,
                                                  leftPupil: (landmarks.leftPupil?.normalizedPoints.first)!,
                                                  rightPupil: (landmarks.rightPupil?.normalizedPoints.first)!,
                                                  ratio: pixelMmRatio)

                    }
                }
            } else {
                print(error!.localizedDescription)
            }
            complete(resultImage)
        }
    
        let vnImage = VNImageRequestHandler(cgImage: source.cgImage!, options: [:])
        try? vnImage.perform([detectFaceRequest])
    }
    
    open func detectCardSize(for source: UIImage, complete: @escaping (CGFloat) -> Void) {
        var cardWidth : CGFloat  = 1
        let detectCreditCardRequest = VNDetectRectanglesRequest { (request, error) in
            if error == nil {
                if let results = request.results as? [VNRectangleObservation] {
                    for rectangles in results {
                       cardWidth = source.size.width * rectangles.boundingBox.size.width
                    }
                }
            }
            complete(cardWidth)
        }
        
        let vnImage = VNImageRequestHandler(cgImage: source.cgImage!, options: [:])
        try? vnImage.perform([detectCreditCardRequest])
    }

    fileprivate func drawOnImage(source: UIImage,
                                 boundingRect: CGRect,
                                 faceLandmarkRegions: [VNFaceLandmarkRegion2D],
                                 leftPupil: CGPoint,
                                 rightPupil: CGPoint,
                                 ratio: CGFloat) -> UIImage {
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
        /* Not drawing all the points
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
        }*/

        // For now, we are just drawing the line between the pupils
        var points: [CGPoint] = []
        points.removeAll()
        let leftPupilPoint = CGPoint(x: CGFloat(boundingRect.origin.x * source.size.width + leftPupil.x * rectWidth), y: CGFloat(boundingRect.origin.y * source.size.height + leftPupil.y * rectHeight))
        let rightPupilPoint = CGPoint(x: CGFloat(boundingRect.origin.x * source.size.width + rightPupil.x * rectWidth), y: CGFloat(boundingRect.origin.y * source.size.height + rightPupil.y * rectHeight))
        points.append(leftPupilPoint)
        points.append(rightPupilPoint)
        
        context.addLines(between: points)
        context.drawPath(using: CGPathDrawingMode.stroke)
        
        
        let pupilDistance = self.distance(from: leftPupilPoint, to: rightPupilPoint) * ratio
        // Range for pupil distance
        if (pupilDistance > 40 && pupilDistance < 81){
            let attrs = [
                NSFontAttributeName: UIFont.systemFont(ofSize: 20),
                NSForegroundColorAttributeName: UIColor.red]
            
            let pupilDistanceString = "\(pupilDistance.rounded()) mm"
            // TODO: This is being rendered mirrored, I have no idea why
            pupilDistanceString.drawFlipped(in: CGRect.init(x: 50, y: 50, width: 100.0, height: 100.0), withAttributes: attrs)
            //pupilDistanceString.draw(at: leftPupilPoint, withAttributes: attrs)

            // Debug purposes
            print("PD: \(pupilDistanceString)")
        }

        let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return coloredImg
    }
}

extension String {

    func drawFlipped(in rect: CGRect, withAttributes attributes: [String: Any]) {
        guard let gc = UIGraphicsGetCurrentContext() else { return }
        gc.saveGState()
        defer { gc.restoreGState() }
        gc.translateBy(x: rect.origin.x, y: rect.origin.y + rect.size.height)
        gc.scaleBy(x: 1, y: -1)
        self.draw(in: CGRect(origin: .zero, size: rect.size), withAttributes: attributes)
    }

}

