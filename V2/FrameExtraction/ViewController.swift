//
//  ImageSliderViewController.swift
//  FrameExtraction
//
//  Created by Avenue Code on 31/10/17.
//


import UIKit
import CoreMotion
import Vision

class ViewController: UIViewController, FrameExtractorDelegate {

    //MARK: - properties
    @IBOutlet weak var instructions: UILabel!
    
    @IBOutlet weak var faceShapeImageView: UIImageView!
    var frameExtractor: FrameExtractor!
    var imagesCollection = [UIImage]()
    var isRunning = true
    var isCapturing = false
    let faceDetector = FaceDetector()
    @IBOutlet weak var frameFront: UIImageView!

    @IBOutlet var captureButton: UIButton!
    @IBOutlet var PDLabel: UILabel!
    var coreMotion = CMMotionManager()

    var drawer = DrawObjects()
    @IBOutlet weak var imageView: UIImageView!
    //MARK: - override methods
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

        self.frameFront.layer.borderWidth = 1.0
        self.frameFront.layer.borderColor = UIColor.red.cgColor
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
                        //self.imagesCollection.append(resultImage)
                        //self.pushToViewer()
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

//        faceDetector.detectFaces(for: image) { [unowned self](success, boundRect, leftPupil, rightPupil, landmarkRegions) in
//            let tupleResult = self.drawer.drawOnImage(source: resultImage,
//                                                      boundingRect: boundRect,
//                                                      faceLandmarkRegions: landmarkRegions,
//                                                      leftPupil: leftPupil,
//                                                      rightPupil: rightPupil,
//                                                      ratio: pixelMmRatio)
//
//        }



        faceDetector.highlightFacePoints(for: image) {[unowned self] (boundsRect, landmarkRegions, face : VNFaceObservation) in

            let resultImage = self.drawer.drawGlasses(personPicture: image, boundingRect: boundsRect, face: face)

//
//
////            let resultImage = self.drawer.drawFacePoints(source: glass,
////                                                         boundingRect: boundsRect,
////                                                         faceLandmarkRegions: landmarkRegions)
//
//            let landmarks = face.landmarks
//            //let pupilDistance = self.distance(from: (landmarks!.leftEye!.normalizedPoints.first)!, to: (landmarks!.rightEye!.normalizedPoints.first)!) * image.size.width
//            let glassImagePupilDistance = 96
//
//
//
//            //            let leftX = (landmarks!.leftEye!.normalizedPoints.first?.x)! * image.size.width
//            //            let leftY = (landmarks!.leftEye!.normalizedPoints.first?.y)! * image.size.height
//            //
//            //            let rightX = (landmarks!.rightEye!.normalizedPoints.first?.x)! * image.size.width
//
//            let noseMinYPoints = landmarks?.noseCrest?.normalizedPoints.min(by: { (lhs, rhs) -> Bool in
//                return lhs.y < rhs.y
//            })
//
//            print(landmarks?.noseCrest?.normalizedPoints)
//            print("Min \(noseMinYPoints)")
//
//            let boundsRectOriginX = boundsRect.origin.x * self.imageView.frame.size.width
//            let boundsRectOriginY = boundsRect.origin.y * self.imageView.frame.size.height
//            let rectWidth = self.imageView.frame.size.width * boundsRect.size.width
//            let rectHeight = self.imageView.frame.size.height * boundsRect.size.height
//
//
//            let positionX = boundsRectOriginX + noseMinYPoints!.x * rectWidth
//            let framePositionY = (1 - noseMinYPoints!.y) * rectHeight + boundsRectOriginY
//
//            print("rect: \(boundsRect)")
//            print("NOSE MIN \(noseMinYPoints!.y)")
//
//            //let glassFrame = self.imageView.convert(CGPoint(x: positionX, y: framePositionY), to: self.view)
//            let glassFrame = CGPoint(x: positionX, y: framePositionY)
//
//            self.positionFrame(point: glassFrame)
//            //let scaleFator = 1 + ((pupilDistance - 140) / 100)
//            //print ("ScaleFactor \(scaleFator)")
//            //self.scaleFrame(scaleFactor : scaleFator )
            self.imageView.image = resultImage
        }
    }

    func positionFrame(point : CGPoint){
        print("frame to = \(point)")
        print("frame before (\(self.frameFront.frame)")
        self.frameFront.center = point
//        self.frameFront.frame.origin.y += self.imageView.frame.origin.y
        print("frame after (\(self.frameFront.frame)")
    }
    func scaleFrame(scaleFactor: CGFloat){
        let layer = self.frameFront.layer
        layer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1)
        layer.zPosition = 1000
    }

    func rotateFaceIndicator(angle:Double) {
        if self.faceShapeImageView.layer != nil {
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
}
