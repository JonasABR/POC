//
//  TutorialViewController.swift
//  FrameExtraction
//
//  Created by Avenue Code on 11/1/17.
//  Copyright © 2017 Avenue Code. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet var presenterView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenterView.isUserInteractionEnabled = true
    }

    @IBAction func pageControlChanged(_ sender: Any) {
        
    }
    @IBAction func skipTutorialButton(_ sender: Any) {
        let captureVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "captureVC")
        self.navigationController?.pushViewController(captureVC, animated: true)
    }
}
