//
//  ImageViewerViewController.swift
//  FrameExtraction
//
//  Created by Avenue Code on 10/31/17.
//  Copyright © 2017 bRo. All rights reserved.
//

import UIKit
import ImageSlideShowSwift


class Image:NSObject, ImageSlideShowProtocol
{
    fileprivate let _image: UIImage

    init(imageFile: UIImage) {
        self._image = imageFile
    }

    func slideIdentifier() -> String {
        return String(describing: "demo")
    }

    func image(completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        completion(self._image,nil)
    }
}

class ImageViewerViewController: UIViewController {

    var imageArray: [UIImage]?
    var dataSource = [ImageSlideShowProtocol]()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let images = self.imageArray {
            for item in images {
                dataSource.append(Image(imageFile: item))
            }

            ImageSlideShowViewController.presentFrom(self){ controller in
                controller.dismissOnPanGesture = true
                controller.slides = self.dataSource
                controller.enableZoom = false
                controller.controllerDidDismiss = {
                    print("Controller Dismissed")
                }
            }

        }



    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
