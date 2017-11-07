//
//  FrameExtractor.swift
//  Created by Avenue Code on 31/10/17.
//

import UIKit
import AVFoundation

protocol FrameExtractorDelegate: class {
    func captured(image: UIImage)
}

class FrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var position = AVCaptureDevicePosition.front
    private let quality = AVCaptureSessionPresetMedium
    
    private var permissionGranted = false
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let captureSession = AVCaptureSession()
    private let context = CIContext()
    private var cardSize : CGFloat = 0
    
    weak var delegate: FrameExtractorDelegate?
    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    // MARK: AVSession configuration
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    private func configureSession() {
        guard permissionGranted else { return }
        captureSession.sessionPreset = quality
        guard let captureDevice = selectCaptureDevice() else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(withMediaType: AVFoundation.AVMediaTypeVideo) else { return }
        let maxFps = CMTimeMake(10,10)

        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = position == .front
    }
    
    private func selectCaptureDevice() -> AVCaptureDevice? {
        return AVCaptureDevice.devices().filter {
            ($0 as AnyObject).hasMediaType(AVMediaTypeVideo) &&
            ($0 as AnyObject).position == position
        }.first as? AVCaptureDevice
    }
    
    // MARK: Sample buffer to UIImage conversion
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let faceDetector = FaceDetector()
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.sync {
            self.delegate?.captured(image: uiImage)
        }

      /*
         For the Pupil Distance use case, we don't need to check (or draw) anything on real time, hence, commenting this out for now
         var squareImage: UIImage?
        faceDetector.detectCardSize(for: uiImage) { (cardSize, _resultImage) in
            squareImage = _resultImage
            self.cardSize = cardSize
        }
        // Only call it if detected the card
        if (self.cardSize != 1){
            faceDetector.highlightFaces(for: squareImage ?? uiImage, cardSize: self.cardSize) { (resultImage, success, pdDistance) in
                DispatchQueue.main.sync {
                    self.delegate?.captured(image: resultImage)
                }
            }
        } else {
            DispatchQueue.main.sync {
                self.delegate?.captured(image: squareImage ?? uiImage)
            }
        }
 */

    }
}
