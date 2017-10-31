//
//  ImageSliderViewController.swift
//  FrameExtraction
//
//  Created by Avenue Brazil on 31/10/17.
//  Copyright © 2017 bRo. All rights reserved.
//

import UIKit

class ImageSliderViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imagesArray: [UIImage]?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = imagesArray?.first
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        if let imagesCount = self.imagesArray?.count, imagesCount > 0 {
            let currentIndex:Int = Int(Float(imagesCount - 1) * sender.value)
            self.imageView.image = self.imagesArray?[currentIndex]
        }
    }

}
