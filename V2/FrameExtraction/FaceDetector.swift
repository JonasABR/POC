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
    
    func getPupilCenter(pupilPoint eye: VNFaceLandmarkRegion2D) -> CGPoint {
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

    
    open func highlightFacePoints(for source: UIImage, complete: @escaping (UIImage, VNFaceObservation) -> Void) {
        
        let detectFaceRequest = VNDetectFaceLandmarksRequest { (request, error) in
            if error == nil {
                if let results = request.results as? [VNFaceObservation] {
                    
                    for faceObservation in results {
                        guard let landmarks = faceObservation.landmarks else {
                            continue
                        }
                        let boundingRect = faceObservation.boundingBox
                        
                        var landmarkRegions: [VNFaceLandmarkRegion2D] = []
                        
                         if let faceContour = landmarks.faceContour {
                            landmarkRegions.append(faceContour)
                         }
                        
                         if let leftEye = landmarks.leftEye {
                            landmarkRegions.append(leftEye)
                         }
                         if let rightEye = landmarks.rightEye {
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
                        
                         if let leftEyebrow = landmarks.leftEyebrow {
                            landmarkRegions.append(leftEyebrow)
                         }
                         if let rightEyebrow = landmarks.rightEyebrow {
                            landmarkRegions.append(rightEyebrow)
                         }
                        
                        let resultImage = self.drawFacePoints(source: source,
                                                           boundingRect: boundingRect,
                                                           faceLandmarkRegions: landmarkRegions)
                        complete(resultImage, faceObservation)
                        return
                        
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
        let vnImage = VNImageRequestHandler(cgImage: source.cgImage!, options: [:])
        try? vnImage.perform([detectFaceRequest])
    }

    fileprivate func drawFacePoints(source: UIImage,
                                 boundingRect: CGRect,
                                 faceLandmarkRegions: [VNFaceLandmarkRegion2D]) -> (UIImage) {
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

    open func highlightFaces(for source: UIImage, pixelMmRatio: CGFloat, complete: @escaping (UIImage, Bool, String) -> Void) {
        
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
                        
                        print("pixelMmRatio: \(pixelMmRatio)")
                        let tupleResult = self.drawOnImage(source: source,
                                                  boundingRect: boundingRect,
                                                  faceLandmarkRegions: landmarkRegions,
                                                  leftPupil: self.getPupilCenter(pupilPoint : landmarks.leftPupil!),
                                                  rightPupil: self.getPupilCenter(pupilPoint : landmarks.rightPupil!),
                                                  ratio: pixelMmRatio)
                        complete(tupleResult.0, tupleResult.1, tupleResult.2)
                        return

                    }
                }
            } else {
                print(error!.localizedDescription)
            }
            complete(source, false, "")
        }
    
        let vnImage = VNImageRequestHandler(cgImage: source.cgImage!, options: [:])
        try? vnImage.perform([detectFaceRequest])
    }
    
    open func detectCardSize(for source: UIImage, complete: @escaping (CGFloat, UIImage?, Bool) -> Void) {
        var imageToDetect: UIImage!
        let context = CIContext();
        
        let ciImage = CIImage.init(cgImage: source.cgImage!)
        if let brightnessFilter = CIFilter(name: "CIColorControls") {
            brightnessFilter.setValue(ciImage, forKey: kCIInputImageKey)
            brightnessFilter.setValue(1.3, forKey: kCIInputContrastKey)
            if let outputImage = brightnessFilter.outputImage {
                let imageRef = context.createCGImage(outputImage, from: outputImage.extent)
                imageToDetect = UIImage.init(cgImage: imageRef!)
            }
        }
        
        var cardWidth : CGFloat  = 1
        var cardHeight : CGFloat  = 1
        
        let detectCreditCardRequest = VNDetectRectanglesRequest { (request, error) in
            var resultImage:UIImage? = source
            if error == nil {
                if let results = request.results as? [VNRectangleObservation] {
                    for rectangles in results {
                        resultImage = self.drawCardBounds(source: resultImage, topLeft: rectangles.topLeft, bottomLeft: rectangles.bottomLeft, topRight: rectangles.topRight, bottomRight: rectangles.bottomRight)
                        cardWidth =  ((resultImage!.size.width * self.distance(from: rectangles.topLeft, to: rectangles.topRight) + resultImage!.size.width * self.distance(from: rectangles.bottomLeft, to: rectangles.bottomRight) ) / 2)
                        cardHeight = ((resultImage!.size.height * self.distance(from: rectangles.topLeft, to: rectangles.bottomLeft) + resultImage!.size.height * self.distance(from: rectangles.topRight, to: rectangles.bottomRight) ) / 2 )
                    }
                }
            }
            let ratio = ((85.6 / cardWidth) + (53.98 / cardHeight)) / 2
            print("Card width: \(cardWidth). Height: \(cardHeight)")
            print("PixelMMRatio width: \(85.6 / cardWidth). Height: \(53.98 / cardHeight). Final ratio: \(ratio) ")

            complete(ratio, resultImage, (cardWidth != 1 && cardHeight != 1))
        }
        detectCreditCardRequest.maximumObservations = 0
        detectCreditCardRequest.minimumAspectRatio = 0.6
        detectCreditCardRequest.maximumAspectRatio = 0.7
        //detectCreditCardRequest.minimumSize = 0.1
        detectCreditCardRequest.quadratureTolerance = 10
        let vnImage = VNImageRequestHandler(cgImage: imageToDetect.cgImage!, options: [:])
        try? vnImage.perform([detectCreditCardRequest])
    }

    func drawCardBounds(source:UIImage?, topLeft:CGPoint, bottomLeft:CGPoint, topRight:CGPoint, bottomRight:CGPoint) -> UIImage? {

        guard let image = source else {
            return nil
        }

        let convertedTopLeft = CGPoint(x: topLeft.x * image.size.width, y: image.size.height - (topLeft.y * image.size.height))
        let convertedTopRight = CGPoint(x: topRight.x * image.size.width, y: image.size.height - (topRight.y * image.size.height))
        let convertedBottomLeft = CGPoint(x: bottomLeft.x * image.size.width, y: image.size.height - (bottomLeft.y * image.size.height))
        let convertedBottomRight = CGPoint(x: bottomRight.x * image.size.width, y: image.size.height - (bottomRight.y * image.size.height))

        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        let context = UIGraphicsGetCurrentContext()!
        context.setLineWidth(3.0)
        context.setStrokeColor(UIColor.green.cgColor)
        
        var points: [CGPoint] = []
        points.append(convertedTopLeft)
        points.append(convertedTopRight)
        points.append(convertedBottomRight)
        points.append(convertedBottomLeft)
        points.append(convertedTopLeft)
        
        context.addLines(between: points)
        context.drawPath(using: CGPathDrawingMode.stroke)

        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }

    fileprivate func drawOnImage(source: UIImage,
                                 boundingRect: CGRect,
                                 faceLandmarkRegions: [VNFaceLandmarkRegion2D],
                                 leftPupil: CGPoint,
                                 rightPupil: CGPoint,
                                 ratio: CGFloat) -> (UIImage, Bool, String) {
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
        let pupilDistance = self.distance(from: leftPupilPoint, to: rightPupilPoint) * ratio
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
        return (coloredImg, true, pupilDistanceString)
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

    func textToImage(drawText: String, inImage: UIImage, atPoint: CGPoint) -> UIImage? {

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
        drawText.draw(in: rect, withAttributes: textFontAttributes)

        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        // End the context now that we have the image we need
        UIGraphicsEndImageContext()

        //Pass the image back up to the caller
        return newImage ?? nil

    }


}


