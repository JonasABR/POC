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

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true;
        self.imageView.image = imagesArray?.first
    }
    
    @IBAction func leftGesture(_ sender: UISwipeGestureRecognizer) {
        if (currentIndex > 0){
            currentIndex-=1
            self.imageView.image = self.imagesArray?[currentIndex]
        }
    }
    
    @IBAction func righGesture(_ sender: UISwipeGestureRecognizer) {
        if (self.imagesArray?.count)! > currentIndex {
            currentIndex+=1
            self.imageView.image = self.imagesArray?[currentIndex]
        }
    }
}
