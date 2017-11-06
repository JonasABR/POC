//
//  ImageSliderViewController.swift
//  FrameExtraction
//
//  Created by Avenue Code on 31/10/17.
//


import UIKit
import CoreMotion

class ViewController: UIViewController, FrameExtractorDelegate {

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
                    print("pitch \(data.attitude.pitch * 180/Double.pi)")

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
        let faceDetector = FaceDetector()
        guard let uiImage = self.imagesCollection.last else { return }
        var cardSize = CGFloat.nan
        faceDetector.detectCardSize(for: uiImage) { (cardSizeDetected, resultImage) in
            cardSize = cardSizeDetected
            // Only call it if detected the card
            if (cardSize != 1){
                faceDetector.highlightFaces(for: uiImage, cardSize: cardSize) { [unowned self](resultImage, success, pdDistance) in
                    if success {
                        if let newImage = pdDistance.textToImage(drawText: pdDistance, inImage: resultImage, atPoint: CGPoint.init(x: 20, y: 20)) {
                            self.imagesCollection = []
                            self.imagesCollection.append(newImage)
                            self.pushToViewer()
                        }
                    }
                }
            }
        }
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
}
