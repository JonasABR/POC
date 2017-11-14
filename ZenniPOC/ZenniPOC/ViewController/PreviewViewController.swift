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
    @IBOutlet weak var guideLabel: UILabel!
    var frameExtractor: VideoCapture?
    let faceDetector = FaceDetector()
    var coreMotion = CMMotionManager()
    var imagesCollection = [UIImage]()
    var drawer = DrawObjects()
    var isRunning = true


    override func viewDidLoad() {
        super.viewDidLoad()
        if previewType == CaptureType.calculatePD {
            self.calculatePDButton.isHidden = false
            self.calculatePDButton.setTitle("Calculate PD", for: .normal)
            self.guideLabel.text = "Look straight and put the credit card on your forehead"
        } else if previewType == CaptureType.facepoints {
            self.calculatePDButton.isHidden = false
            self.calculatePDButton.setTitle("Finished", for: .normal)
            self.guideLabel.text = "Turn your face slowly left and right and tap on Finish"
        } else {
            self.calculatePDButton.isHidden = true
            self.guideLabel.text = "Check the glass frame in real time"
        }
        self.coreMotion.deviceMotionUpdateInterval = 0.1;
        coreMotion.startDeviceMotionUpdates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imagesCollection = [UIImage]()
        self.isRunning = true
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
                if self.previewType == CaptureType.calculatePD || self.previewType == CaptureType.facepoints {
                    self.imagesCollection.append(image)
                }
            }
            self.imageView.image = image

            if self.previewType == CaptureType.realtimeGlasses {
                faceDetector.highlightFacePoints(for: image) {[unowned self] (boundsRect, landmarkRegions, face : VNFaceObservation) in
                    self.imageView.image = image

                    if self.previewType == CaptureType.realtimeGlasses {
                        let resultImage = self.drawer.drawGlasses(personPicture: image, boundingRect: boundsRect, face: face)
                        self.imageView.image = resultImage
                    }
                }
            }
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
        self.isRunning = false
        if previewType == CaptureType.calculatePD {
            calculatePDAction()

        } else if previewType == CaptureType.facepoints {
            showFacePoints()
        }
    }

    func calculatePDAction() {
        guard let originalImage = self.imagesCollection.last else { return }
        print("ArraySize: \(self.imagesCollection.count)")

        faceDetector.detectCardSize(for: originalImage) { [unowned self] (pixelMmRatio, cardPoints, success) in
            let resultImage = self.drawer.drawCardBounds(source: originalImage, bounds: cardPoints) ?? originalImage
            if (pixelMmRatio != 1 && success){
                self.faceDetector.detectFaces(for: resultImage) { [unowned self](success, boundRect, leftPupil, rightPupil, landmarkRegions) in
                    if success {
                        let tupleResult = self.drawer.drawOnImage(source: resultImage,
                                                                  boundingRect: boundRect,
                                                                  faceLandmarkRegions: landmarkRegions,
                                                                  leftPupil: leftPupil,
                                                                  rightPupil: rightPupil,
                                                                  ratio: pixelMmRatio)

                        print("Cards AND face!")
                        if let newImage = tupleResult.1.textToImage(inImage: tupleResult.0, atPoint: CGPoint.init(x: 20, y: 20)) {
                            self.imagesCollection = []
                            self.imagesCollection.append(newImage)
                            self.pushToViewer()
                        }
                    }
                    else{
                        print("Card, but no faces")
                        self.imagesCollection = []
                        self.imagesCollection.append(resultImage)
                        self.pushToViewer()
                    }
                }
            } else{
                self.faceDetector.detectFaces(for: resultImage) { [unowned self](success, boundRect, leftPupil, rightPupil, landmarkRegions) in
                    if success {
                        let tupleResult = self.drawer.drawOnImage(source: resultImage,
                                                                  boundingRect: boundRect,
                                                                  faceLandmarkRegions: landmarkRegions,
                                                                  leftPupil: leftPupil,
                                                                  rightPupil: rightPupil,
                                                                  ratio: pixelMmRatio)


                        print("No card, showing the pupils tho")
                        if let newImage = tupleResult.1.textToImage(inImage: tupleResult.0, atPoint: CGPoint.init(x: 20, y: 20)) {
                            self.imagesCollection = []
                            self.imagesCollection.append(newImage)
                            self.pushToViewer()
                        }
                    }
                }
            }
        }
    }

    func showFacePoints() {
        skipFrames()
        pushToViewer()
    }

    func pushToViewer() {
        if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageSliderViewController") as? ImageSliderViewController {
            vc.imagesArray = self.imagesCollection
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
