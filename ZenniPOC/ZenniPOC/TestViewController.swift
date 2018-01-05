//
//  TestViewController.swift
//  ZenniPOC
//
//  Created by Avenue Code on 11/23/17.
//  Copyright © 2017 AvenueCode. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    @IBOutlet var imageViewGlass: UIImageView!
    @IBOutlet var leftImageViewGlass: UIImageView!
    @IBOutlet var rightImageViewGlass: UIImageView!
    @IBOutlet var textFieldAngle: UITextField!
    @IBOutlet var textFieldX: UITextField!
    @IBOutlet var textFieldY: UITextField!
    @IBOutlet var textFieldZ: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let openCV = OpenCVWrapper()
        let image = UIImage(named: "imageToDetect")
        let newImage = openCV.proccessImage(image)
        imageViewGlass.image = newImage

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown(_:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)


        let width = leftImageViewGlass.frame.width

        var transform = CATransform3DMakeTranslation(width, 0.0, 0)
        transform.m34 = -1.0 / 500.0
        transform = CATransform3DRotate(transform, .pi / 2, 0.0, 1.0, 0.0)
        //rightImageViewGlass.center = CGPoint(x: rightImageViewGlass.frame.width / 2, y: rightImageViewGlass.frame.height / 2)
        rightImageViewGlass.layer.transform = transform

        var transform2 = CATransform3DMakeTranslation(-width, 0.0, 0)
        transform2.m34 = -1.0 / 500.0
        transform2 = CATransform3DRotate(transform2, -(.pi / 2), 0.0, 1.0, 0.0)
        leftImageViewGlass.layer.transform = transform2
        imageViewGlass.layer.isDoubleSided = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func regenerate(_ sender: Any) {
        let x = CGFloat(Double(textFieldX.text!)!)
        let y = CGFloat(Double(textFieldY.text!)!)
        let z = CGFloat(Double(textFieldZ.text!)!)

        var rotationTransform = CATransform3DMakeRotation(CGFloat(Double(textFieldAngle.text!)!.degressToRadians()) , x, y, z)
//        rotationTransform.m34 = -1.0 / 500.0
        let concat = CATransform3DConcat(imageViewGlass.layer.transform, rotationTransform)
        let concatleft = CATransform3DConcat(leftImageViewGlass.layer.transform, rotationTransform)
        let concatright = CATransform3DConcat(rightImageViewGlass.layer.transform, rotationTransform)
        imageViewGlass.layer.transform = concat
        leftImageViewGlass.layer.transform = concatleft
        rightImageViewGlass.layer.transform = concatright
        
    }

    @IBAction func swipeRight(_ sender: Any) {
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 500.0
        perspective = CATransform3DRotate(perspective, CGFloat(-(Double.pi/4)), 0, 1, 0)
        self.view.layer.sublayerTransform = perspective;

    }
    @IBAction func swipeLeft(_ sender: Any) {
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 500.0
        perspective = CATransform3DRotate(perspective, CGFloat((Double.pi/4)), 0, 1, 0)
        self.view.layer.sublayerTransform = perspective;
    }

    @IBAction func swipeDown(_ sender: Any) {
        var perspective = CATransform3DIdentity
        perspective = CATransform3DRotate(perspective, 0, 0, 1, 0)
        self.view.layer.sublayerTransform = perspective;
    }



}
