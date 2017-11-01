//
//  ImageSliderViewController.swift
//  FrameExtraction
//
//  Created by Avenue Code on 31/10/17.
//

import UIKit

class ImageSliderViewController: UIViewController {
  
    private var currentIndex:Int = 0
    @IBOutlet weak var imageView: UIImageView!
    var imagesArray: [UIImage]?
    private var startLocation: CGPoint = CGPoint.zero
    var pixelsPerImage:CGFloat {
        guard let imagesArray = self.imagesArray else {
            return CGFloat.greatestFiniteMagnitude
        }
        return self.imageView.frame.width / CGFloat(imagesArray.count)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.isUserInteractionEnabled = true;
        self.imageView.image = imagesArray?.first
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didReceivePanGesture(panGesture:)))
        self.imageView.addGestureRecognizer(panGestureRecognizer)
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

                self.imageView.image = imagesArray[newIndex]
                if panGesture.state == .ended {
                    self.currentIndex = newIndex
                }
            default:
                break
            }
        }
    }
}
