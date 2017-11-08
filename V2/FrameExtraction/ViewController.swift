//
//  ImageSliderViewController.swift
//  FrameExtraction
//
//  Created by Avenue Code on 31/10/17.
//


import UIKit
import CoreMotion

class ViewController: UIViewController, FrameExtractorDelegate {

    @IBOutlet weak var instructions: UILabel!
    
    @IBOutlet weak var frameFront: UIImageView!
    @IBOutlet weak var faceShapeImageView: UIImageView!
    var frameExtractor: FrameExtractor!
    var imagesCollection = [UIImage]()
    var isRunning = true
    var isCapturing = false
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var PDLabel: UILabel!
    var coreMotion = CMMotionManager()

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
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

    func initFrameExtractor() {
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
    }

    func pushToViewer() {
        if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageSliderViewController") as? ImageSliderViewController {
            vc.imagesArray = self.imagesCollection
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func stopButton(_ sender: Any) {
        if isCapturing {
            self.captureButton.setTitle("Start", for: .normal)
            self.isRunning = false
            self.isCapturing = false
            skipFrames()
            markFacePoints()
            pushToViewer()
        }
        else{
            self.isRunning = true
            self.captureButton.setTitle("Stop", for: .normal)
            self.imagesCollection = []
            self.isCapturing = true
        }
    }

    @IBAction func calculatePD(_ sender: Any) {
        self.isRunning = false
        let faceDetector = FaceDetector()
        guard let originalImage = self.imagesCollection.last else { return }
        print("ArraySize: \(self.imagesCollection.count)")

        var squareImage: UIImage!
 
        faceDetector.detectCardSize(for: originalImage) { (pixelMmRatio, resultImage, success) in
            squareImage = resultImage
            if (pixelMmRatio != 1 && success){
                faceDetector.highlightFaces(for: resultImage!, pixelMmRatio: pixelMmRatio) { [unowned self](newresultImage, success, pdDistance) in
                    if success {
                        print("Cards AND face!")
                        if let newImage = pdDistance.textToImage(drawText: pdDistance, inImage: newresultImage, atPoint: CGPoint.init(x: 20, y: 20)) {
                            self.imagesCollection = []
                            self.imagesCollection.append(newImage)
                            self.pushToViewer()
                        }
                    }
                    else{
                        print("Card, but no faces")
                        self.imagesCollection = []
                        self.imagesCollection.append(newresultImage)
                        self.pushToViewer()
                    }
                 }
            }
            else{
                faceDetector.highlightFaces(for: resultImage!, pixelMmRatio: pixelMmRatio) { [unowned self](newresultImage, success, pdDistance) in
                    if success {
                        print("No card, showing the pupils tho")
                        if let newImage = pdDistance.textToImage(drawText: pdDistance, inImage: newresultImage, atPoint: CGPoint.init(x: 20, y: 20)) {
                            self.imagesCollection = []
                            self.imagesCollection.append(newImage)
                            self.pushToViewer()
                        }
                    }
                }
            }
        }
        self.isRunning = true
    }

    func markFacePoints(){
        let faceDetector = FaceDetector()
        var markedImagesCollection = [UIImage]()

        for image in self.imagesCollection{
            faceDetector.highlightFacePoints(for: image) { (newresultImage) in
                markedImagesCollection.append(newresultImage)
            }
        }
        self.imagesCollection = markedImagesCollection
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

    func captured(image: UIImage) {
        if isRunning {
            DispatchQueue.main.async {
                self.imagesCollection.append(image)
            }
        }
        imageView.image = image
    }

    func rotateFaceIndicator(angle:Double) {
        let layer = self.faceShapeImageView.layer
        if (abs(angle) > 3){
            layer.backgroundColor = UIColor(red:1.0, green: 0.0, blue: 0.0, alpha: 0.2).cgColor
            instructions.text = "Tilt your phone to upright position"
        }
        else{
            layer.backgroundColor = UIColor(red:0.0, green: 1.0, blue: 0.0, alpha: 0.4).cgColor
            instructions.text = "Make sure your face is within the green rectangle"
        }
        
        var rotationAndPerspectiveTransform = CATransform3DIdentity
        rotationAndPerspectiveTransform.m34 = 1.0 / -200
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, CGFloat(angle * -Double.pi / 180.0), 1.0, 0, 0.0)
        layer.transform = rotationAndPerspectiveTransform
        layer.zPosition = 1000
    }
}
