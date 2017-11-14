//
//  ViewController.swift
//  ZenniPOC
//
//  Created by Avenue Code on 11/14/17.
//  Copyright © 2017 AvenueCode. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func calculatePDButton(_ sender: Any) {
        if let preview = storyboard?.instantiateViewController(withIdentifier: "preview") as? PreviewViewController {
            preview.previewType = CaptureType.calculatePD
            self.navigationController?.pushViewController(preview, animated: true)
        }
    }

    @IBAction func realTimeGlassButton(_ sender: Any) {
        if let preview = storyboard?.instantiateViewController(withIdentifier: "preview") as? PreviewViewController {
            preview.previewType = CaptureType.realtimeGlasses
            self.navigationController?.pushViewController(preview, animated: true)
        }
    }

    @IBAction func facePointsButton(_ sender: Any) {
        if let preview = storyboard?.instantiateViewController(withIdentifier: "preview") as? PreviewViewController {
            preview.previewType = CaptureType.facepoints
            self.navigationController?.pushViewController(preview, animated: true)
        }
    }
}

