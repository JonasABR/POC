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
    @IBOutlet var captureButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFrameExtractor()
    }

    func initFrameExtractor() {
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
    }

    @IBAction func stopButton(_ sender: Any) {
        if frameExtractor != nil {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "ImageSliderViewController") as? ImageSliderViewController {
                skipFrames()
                vc.imagesArray = self.imagesCollection
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func skipFrames(){
        var imagesCollection = [UIImage]()
        let imageCount = self.imagesCollection.count
        let neededImage = 30
        let stepSize = imageCount / neededImage
       
        // The first 10 frames are, while the camera is starting, ignoring them
        imagesCollection.append(self.imagesCollection[10])

        for currentImage in 1..<neededImage {
            let currentIndex = stepSize * currentImage
            imagesCollection.append(self.imagesCollection[currentIndex])
        }
        
        self.imagesCollection = imagesCollection

    }

    func captured(image: UIImage) {
        DispatchQueue.main.async {
            self.imagesCollection.append(image)
        }
        imageView.image = image
    }
    
}

