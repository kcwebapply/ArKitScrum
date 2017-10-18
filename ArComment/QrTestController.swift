//
//  QrTestController.swift
//  ArComment
//
//  Created by 和田　継嗣 on 2017/07/16.
//  Copyright © 2017年 和田　継嗣. All rights reserved.
//

import Foundation
import UIKit
import  AVFoundation
class QrTestController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        let input = try? AVCaptureDeviceInput(device: device!)
        session.addInput(input!)
        
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue:DispatchQueue.main)
        session.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.frame = view.bounds
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(layer)
        
        session.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        print(metadataObjects.flatMap { $0.stringValue })
    }
}
