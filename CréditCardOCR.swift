//
//  CréditCardOCR.swift
//  ocr-POC
//
//  Created by imac luc on 21/10/2024.
//

import SwiftUI
import AVFoundation
import Vision

struct CreditCardScannerView: UIViewControllerRepresentable {
    
    var onCreditCardNumberDetected: (String) -> Void
    
    var scanArea: CGRect {
        .init(x: 20,
              y: UIScreen.main.bounds.height / 2,
              width: UIScreen.main.bounds.width - 40,
              height: 50)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { 
            return viewController
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { 
            return viewController
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        
        let rectangleView = UIView()
        rectangleView.frame = scanArea
        rectangleView.layer.borderColor = UIColor.yellow.cgColor
        rectangleView.layer.borderWidth = 2.0
        rectangleView.layer.cornerRadius = 10
        rectangleView.clipsToBounds = true
        viewController.view.addSubview(rectangleView)
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        
        var parent: CreditCardScannerView
        var visionRequest = [VNRequest]()
        
        // usecase avec la regex
        
        init(_ parent: CreditCardScannerView) {
            self.parent = parent
            super.init()
            
            let textRequest = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
            textRequest.regionOfInterest = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
            textRequest.recognitionLevel = .accurate

            self.visionRequest = [textRequest]
        }

        private func isValidIBAN(_ iban: String) -> Bool {
            let ibanRegex = "^[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}$"
            let ibanPredicate = NSPredicate(format: "SELF MATCHES %@", ibanRegex)
            return ibanPredicate.evaluate(with: iban)
        }
        
        func handleDetectedText(request: VNRequest?, error: Error?) {
            
            guard let observations = request?.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            var creditCardNumber: String?
            
            for observation in observations {
                guard let candidate = observation.topCandidates(1).first else { continue }
                let text = candidate.string.replacingOccurrences(of: " ", with: "")
                
                if isValidIBAN(text) {
                    print(text)
                    creditCardNumber = text
                    break
                }
            }
            
            if let creditCardNumber = creditCardNumber {
                DispatchQueue.main.async {
                    self.parent.onCreditCardNumberDetected(creditCardNumber)
                }
            }
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            var requestOptions:[VNImageOption: Any] = [:]
            
            if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
                requestOptions = [.cameraIntrinsics: cameraData]
            }
            
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: requestOptions)

            try? imageRequestHandler.perform(self.visionRequest)
        }
    }
}
