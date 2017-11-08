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
        if isRunning {
            self.captureButton.setTitle("Continue", for: .normal)
            self.isRunning = false
            skipFrames()
            pushToViewer()
        } else {
            self.isRunning = true
            self.captureButton.setTitle("Stop", for: .normal)

        }
    }

    @IBAction func calculatePD(_ sender: Any) {
        self.isRunning = false
        let faceDetector = FaceDetector()
        guard let originalImage = self.imagesCollection.last else { return }
        print("ArraySize: \(self.imagesCollection.count)")

        var pxMmRatio = CGFloat.nan
        var squareImage: UIImage!

       /* self.faceShapeImageView.isHidden = true
        UIGraphicsBeginImageContextWithOptions(self.faceShapeImageView.frame.size, false, UIScreen.main.scale)
        self.view.drawHierarchy(in: CGRect.init(x: -self.faceShapeImageView.frame.origin.x, y: -self.faceShapeImageView.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.height ), afterScreenUpdates: true)
        let CreditCardCroppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.faceShapeImageView.isHidden = false
         */
 
 
        faceDetector.detectCardSize(for: originalImage) { (pixelMmRatio, resultImage) in
            squareImage = resultImage
//            // Only call it if detected the card
            if (pixelMmRatio != 1){
                faceDetector.highlightFaces(for: originalImage, pixelMmRatio: pixelMmRatio) { [unowned self](resultImage, success, pdDistance) in
                    if success {
                        print("Cards AND face!")
                        if let newImage = pdDistance.textToImage(drawText: pdDistance, inImage: resultImage, atPoint: CGPoint.init(x: 20, y: 20)) {
                            self.imagesCollection = []
                            self.imagesCollection.append(newImage)
                            self.pushToViewer()
                        }
                    }
                    else{
                        print("Card, but no faces")
                        self.imagesCollection = []
                        self.imagesCollection.append(squareImage)
                        self.pushToViewer()
                    }
                 }
            }
            else{
                print("No card!")
                self.imagesCollection = []
                self.imagesCollection.append(squareImage)
                self.pushToViewer()
            }
        }
        self.isRunning = true
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
