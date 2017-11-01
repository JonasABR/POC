//
//  ImageSliderViewController.swift
//  FrameExtraction
//
//  Created by Avenue Code on 31/10/17.
//


import UIKit

class ViewController: UIViewController, FrameExtractorDelegate {

    var frameExtractor: FrameExtractor!
    var imagesCollection = [UIImage]()
    var isRunning = false
    @IBOutlet var captureButton: UIButton!

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initFrameExtractor()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.isRunning = false
        self.imagesCollection = [UIImage]()
        self.captureButton.setTitle("Continue", for: .normal)
    }

    func initFrameExtractor() {
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
    }

    @IBAction func stopButton(_ sender: Any) {
        if isRunning {
            self.captureButton.setTitle("Continue", for: .normal)
            self.isRunning = false
            if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageSliderViewController") as? ImageSliderViewController {
                skipFrames()
                vc.imagesArray = self.imagesCollection
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            self.isRunning = true
            self.captureButton.setTitle("Stop", for: .normal)

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
