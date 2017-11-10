 //
//  ImageSliderViewController.swift
//  FrameExtraction
//
//  Created by Avenue Code on 31/10/17.
//

import UIKit
import Vision

class ImageSliderViewController: UIViewController {
  
    private var currentIndex:Int = 0
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var frameFront: UIImageView!
    var imagesArray: [UIImage]?
    var drawer = DrawObjects()
    private var startLocation: CGPoint = CGPoint.zero
    var pixelsPerImage:CGFloat {
        guard let imagesArray = self.imagesArray else {
            return CGFloat.greatestFiniteMagnitude
        }
        return self.imageView.frame.width / CGFloat(imagesArray.count)
    }

    func distance(from lhs: CGPoint, to rhs: CGPoint) -> CGFloat {
        return hypot(lhs.x.distance(to: rhs.x), lhs.y.distance(to: rhs.y))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.isUserInteractionEnabled = true;
        self.imageView.image = imagesArray?.first
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didReceivePanGesture(panGesture:)))
        self.imageView.addGestureRecognizer(panGestureRecognizer)
        self.markFacePoints(image: (imagesArray?.first)!)
    }
    
    func markFacePoints(image : UIImage){
        let faceDetector = FaceDetector()
        faceDetector.highlightFacePoints(for: image) {[unowned self] (boundsRect, landmarkRegions, face : VNFaceObservation) in
            let resultImage = self.drawer.drawFacePoints(source: image,
                                                       boundingRect: boundsRect,
                                                       faceLandmarkRegions: landmarkRegions)

            let landmarks = face.landmarks
            let pupilDistance = self.distance(from: (landmarks!.leftEye!.normalizedPoints.first)!, to: (landmarks!.rightEye!.normalizedPoints.first)!) * image.size.width
            let glassImagePupilDistance = 96



//            let leftX = (landmarks!.leftEye!.normalizedPoints.first?.x)! * image.size.width
//            let leftY = (landmarks!.leftEye!.normalizedPoints.first?.y)! * image.size.height
//
//            let rightX = (landmarks!.rightEye!.normalizedPoints.first?.x)! * image.size.width

            let noseMinYPoints = landmarks?.noseCrest?.normalizedPoints.min(by: { (lhs, rhs) -> Bool in
                return lhs.y < rhs.y
            })

            let positionX = noseMinYPoints!.x * image.size.width
            let framePositionY = (noseMinYPoints!.y * image.size.height)


            let glassFrame = self.imageView.convert(CGPoint(x: positionX, y: framePositionY), to: self.view)
            //let glassFrame = CGPoint(x: positionX, y: framePositionY)

            self.positionFrame(point: glassFrame)
            //let scaleFator = 1 + ((pupilDistance - 140) / 100)
            //print ("ScaleFactor \(scaleFator)")
            //self.scaleFrame(scaleFactor : scaleFator )
            self.imageView.image = resultImage
        }
    }
    
    func positionFrame(point : CGPoint){
        print("frame to = \(point)")
        print("frame before (\(self.frameFront.frame)")
        self.frameFront.center = point
        print("frame after (\(self.frameFront.frame)")
    }
    func scaleFrame(scaleFactor: CGFloat){
        let layer = self.frameFront.layer
        layer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1)
        layer.zPosition = 1000
    }
    
    func roteteFrame(angle:Double) {
        let layer = self.frameFront.layer
        var rotationAndPerspectiveTransform = CATransform3DIdentity
        rotationAndPerspectiveTransform.m34 = 1.0 / -200
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, CGFloat(angle * -Double.pi / 180.0), 0.0, 1.0, 0.0)
        layer.transform = rotationAndPerspectiveTransform
        layer.zPosition = 1000
    }


    func didReceivePanGesture(panGesture:UIPanGestureRecognizer) {
        if let imagesArray = self.imagesArray {
            switch panGesture.state {
            case .began:
                self.startLocation = panGesture.location(in: self.imageView)
                print(self.startLocation.x)
            case .changed, .ended:
                let currentLocation = panGesture.location(in: self.imageView)
                let dx = CGFloat(currentLocation.x - self.startLocation.x)
                let offset = Int((dx / self.pixelsPerImage).rounded())
                var newIndex = self.currentIndex + offset

                if newIndex < 0 {
                    newIndex = 0
                } else if newIndex >= imagesArray.count {
                    newIndex = imagesArray.count - 1
                }

                markFacePoints(image: imagesArray[newIndex])
                if panGesture.state == .ended {
                    self.currentIndex = newIndex
                }
            default:
                break
            }
        }
    }
}
