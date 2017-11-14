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
    
    open func highlightFacePoints(for source: UIImage, complete: @escaping (_ boundsRect: CGRect, _ landmarkRegions: [VNFaceLandmarkRegion2D], VNFaceObservation) -> Void) {
        let detectFaceRequest = VNDetectFaceLandmarksRequest {(request, error) in
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
                        complete(boundingRect, landmarkRegions, faceObservation)
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
        let vnImage = VNImageRequestHandler(cgImage: source.cgImage!, options: [:])
        try? vnImage.perform([detectFaceRequest])
    }

    

    open func detectFaces(for source: UIImage, complete: @escaping (_ success: Bool, _ boundRect: CGRect, _ leftPupil: CGPoint, _ rightPupil: CGPoint, _ landmarkRegions: [VNFaceLandmarkRegion2D]) -> Void) {
        let detectFaceRequest = VNDetectFaceLandmarksRequest { (request, error) in
            if error == nil {
                if let results = request.results as? [VNFaceObservation] {
                    
                    for faceObservation in results {
                        guard let landmarks = faceObservation.landmarks else {
                            continue
                        }
                        let boundingRect = faceObservation.boundingBox
                      
                        var landmarkRegions: [VNFaceLandmarkRegion2D] = []

                        complete(true, boundingRect, self.getPupilCenter(pupilPoint : landmarks.leftPupil!), self.getPupilCenter(pupilPoint : landmarks.rightPupil!), landmarkRegions)
                        return
                    }
                }
                complete(false, CGRect.zero, CGPoint.zero, CGPoint.zero, [VNFaceLandmarkRegion2D]())
            } else {
                print(error!.localizedDescription)
                complete(false, CGRect.zero, CGPoint.zero, CGPoint.zero, [VNFaceLandmarkRegion2D]())
            }
        }
    
        let vnImage = VNImageRequestHandler(cgImage: source.cgImage!, options: [:])
        try? vnImage.perform([detectFaceRequest])
    }
    
    open func detectCardSize(for source: UIImage, complete: @escaping (_ pixelMmRatio: CGFloat, _ cardPoints: [CGPoint], _ success: Bool) -> Void) {
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
        var drawPoints = [CGPoint]()
        let detectCreditCardRequest = VNDetectRectanglesRequest { (request, error) in
            if error == nil {
                if let results = request.results as? [VNRectangleObservation] {
                    for rectangles in results {
                        drawPoints = [rectangles.topLeft, rectangles.bottomLeft, rectangles.bottomRight,rectangles.topRight, rectangles.topLeft]
                        cardWidth =  ((source.size.width * rectangles.topLeft.distance(to: rectangles.topRight) + source.size.width * rectangles.bottomLeft.distance(to: rectangles.bottomRight) ) / 2)
                        cardHeight = ((source.size.height * rectangles.topLeft.distance(to: rectangles.bottomLeft) + source.size.height * rectangles.topRight.distance(to: rectangles.bottomRight) ) / 2 )
                    }
                }
            }
            let ratio = ((85.6 / cardWidth) + (53.98 / cardHeight)) / 2
            print("Card width: \(cardWidth). Height: \(cardHeight)")
            print("PixelMMRatio width: \(85.6 / cardWidth). Height: \(53.98 / cardHeight). Final ratio: \(ratio) ")

            complete(ratio, drawPoints, (cardWidth != 1 && cardHeight != 1))
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
