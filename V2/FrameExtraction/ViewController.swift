//
//  ViewController.swift
//  Created by Bobo on 29/12/2016.
//

import UIKit

class ViewController: UIViewController, FrameExtractorDelegate {
    
    var frameExtractor: FrameExtractor!
    var imagesCollection = [UIImage]()
    @IBOutlet var captureButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func flipButton(_ sender: UIButton) {
        frameExtractor.flipCamera()
    }
    
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
            self.frameExtractor = nil
            self.captureButton.setTitle("Start", for: .normal)
        } else {
            initFrameExtractor()
            self.captureButton.setTitle("Stop", for: .normal)
        }
    }

    @IBAction func showImagesButton(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ImageSliderViewController") as? ImageSliderViewController {
            vc.imagesArray = self.imagesCollection
            self.navigationController?.pushViewController(vc, animated: true)

        }
    }

    
    func captured(image: UIImage) {
        DispatchQueue.main.async {
            self.imagesCollection.append(image)
        }
        imageView.image = image
    }
    
}

