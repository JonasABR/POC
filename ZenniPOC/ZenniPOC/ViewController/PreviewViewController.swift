//
//  PreviewViewController.swift
//  ZenniPOC
//
//  Created by Avenue Code on 11/14/17.
//  Copyright © 2017 AvenueCode. All rights reserved.
//

import UIKit
import CoreMotion
import Vision


class PreviewViewController: UIViewController, VideoCaptureDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var calculatePDButton: UIButton!
    var previewType = CaptureType.none
    var frameExtractor: VideoCapture?
    let faceDetector = FaceDetector()
    var coreMotion = CMMotionManager()
    var imagesCollection = [UIImage]()
    var drawer = DrawObjects()
    var isRunning = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.calculatePDButton.isHidden = !(previewType == CaptureType.calculatePD)
        self.coreMotion.deviceMotionUpdateInterval = 0.1;
        coreMotion.startDeviceMotionUpdates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initFrameExtractor()
        if coreMotion.isDeviceMotionActive {
            coreMotion.startDeviceMotionUpdates(to: OperationQueue.main) { (data: CMDeviceMotion?, error) in
                if let data = data {
                    var angle = data.attitude.pitch * 180/Double.pi - 90 // Angle relative to top position
                    if (data.gravity.z > 0){
                        angle *= -1
                    }
                    self.rotateFaceIndicator(angle: angle)
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.frameExtractor = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.isRunning = false
        self.imagesCollection = [UIImage]()
    }

    //MARK: - Events
    func initFrameExtractor() {
        frameExtractor = VideoCapture()
        frameExtractor?.delegate = self
    }

    func skipFrames(){
        var imagesCollection = [UIImage]()
        let imageCount = self.imagesCollection.count
        let neededImage = 30
        let stepSize = imageCount / neededImage

        for currentImage in 1..<neededImage {
            let currentIndex = stepSize * currentImage
            imagesCollection.append(self.imagesCollection[currentIndex])
        }

        self.imagesCollection = imagesCollection

    }

    func captured(image: UIImage?) {
        if let image = image {
            if isRunning {
                DispatchQueue.main.async {
                    self.imagesCollection.append(image)
                }
            }

            self.imageView.image = image
        }
    }

    func rotateFaceIndicator(angle:Double) {
//        if self.faceShapeImageView.layer != nil {
//            let layer = self.faceShapeImageView.layer
//            if (abs(angle) > 3){
//                layer.backgroundColor = UIColor(red:1.0, green: 0.0, blue: 0.0, alpha: 0.2).cgColor
//                instructions.text = "Tilt your phone to upright position"
//            }
//            else{
//                layer.backgroundColor = UIColor(red:0.0, green: 1.0, blue: 0.0, alpha: 0.4).cgColor
//                instructions.text = "Make sure your face is within the green rectangle"
//            }
//
//            var rotationAndPerspectiveTransform = CATransform3DIdentity
//            rotationAndPerspectiveTransform.m34 = 1.0 / -200
//            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, CGFloat(angle * -Double.pi / 180.0), 1.0, 0, 0.0)
//            layer.transform = rotationAndPerspectiveTransform
//            layer.zPosition = 1000
//        }
    }

    @IBAction func calculatePD(_ sender: Any) {

    }
}
