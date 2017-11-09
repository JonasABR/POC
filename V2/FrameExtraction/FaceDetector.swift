//
//  FaceDetector.swift
//  FaceVision
//
//  Created by Avenue Code on 31/10/17
//

import UIKit
import Vision

class FaceDetector {
    var draw = DrawObjects()
    
    
    
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

    
    open func highlightFacePoints(for source: UIImage, complete: @escaping (UIImage) -> Void) {
        
        let detectFaceRequest = VNDetectFaceLandmarksRequest { [unowned self] (request, error) in
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
                        
                        let resultImage = self.draw.drawFacePoints(source: source,
                                                           boundingRect: boundingRect,
                                                           faceLandmarkRegions: landmarkRegions)
                        complete(resultImage)
                        return
                        
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
            complete(source)
        }
        
        let vnImage = VNImageRequestHandler(cgImage: source.cgImage!, options: [:])
        try? vnImage.perform([detectFaceRequest])
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
                        let tupleResult = self.draw.drawOnImage(source: source,
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
        
        let detectCreditCardRequest = VNDetectRectanglesRequest { [unowned self](request, error) in
            var resultImage:UIImage? = source
            if error == nil {
                if let results = request.results as? [VNRectangleObservation] {
                    for rectangles in results {
                        resultImage = self.draw.drawCardBounds(source: resultImage, topLeft: rectangles.topLeft, bottomLeft: rectangles.bottomLeft, topRight: rectangles.topRight, bottomRight: rectangles.bottomRight)
                        cardWidth =  ((resultImage!.size.width * self.draw.distance(from: rectangles.topLeft, to: rectangles.topRight) + resultImage!.size.width * self.draw.distance(from: rectangles.bottomLeft, to: rectangles.bottomRight) ) / 2)
                        cardHeight = ((resultImage!.size.height * self.draw.distance(from: rectangles.topLeft, to: rectangles.bottomLeft) + resultImage!.size.height * self.draw.distance(from: rectangles.topRight, to: rectangles.bottomRight) ) / 2 )
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


