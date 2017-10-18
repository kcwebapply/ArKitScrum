//
//  QrController.swift
//  ArComment
//
//  Created by 和田　継嗣 on 2017/07/16.
//  Copyright © 2017年 和田　継嗣. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class QRController:UIViewController,AVCaptureMetadataOutputObjectsDelegate{
    
   
    let captureSession = AVCaptureSession()
    var videoLayer: AVCaptureVideoPreviewLayer?
    
    var qrView: UIView!
    var backView:UIView!
    var previewView: UIView!
    var textField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setQrCode()
    }
    
    func setQrCode(){
        self.backView = UIView(frame:self.view.frame)
        self.view.addSubview(backView)
        self.previewView = UIView(frame:CGRect(x:0,y:0,width:self.view.frame.size.width,height:self.view.frame.size.height))
        self.backView.addSubview(previewView)
        self.textField = UITextView(frame:CGRect(x:0,y:self.view.frame.size.height-90,width:self.view.frame.size.width,height:90))
        self.backView.addSubview(self.textField)
        
        // QRコードをマークするビュー
        qrView = UIView()
        qrView.layer.borderWidth = 4
        qrView.layer.borderColor = UIColor.red.cgColor
        qrView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        view.addSubview(qrView)
        
        // 入力（背面カメラ）
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice!)
        captureSession.addInput(videoInput)
        
        // 出力（メタデータ）
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        
        // QRコードを検出した際のデリゲート設定
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // QRコードの認識を設定
        metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        // プレビュー表示
        videoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        videoLayer?.frame = previewView.bounds
        videoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewView.layer.addSublayer(videoLayer!)
        
        // セッションの開始
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    
    //QRを認識したときに呼ばれる
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection){

        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject]{
            // QRコードのデータかどうかの確認
            if metadata.type == AVMetadataObject.ObjectType.qr {
                // 検出位置を取得
                let barCode = videoLayer?.transformedMetadataObject(for: metadata) as! AVMetadataMachineReadableCodeObject
                qrView!.frame = barCode.bounds
                if metadata.stringValue != nil {
                    // 検出データを取得
                    textField.text = metadata.stringValue!
                    let arController = ARController()
                    arController.url = metadata.stringValue
                    self.present(arController, animated: true, completion: nil)
                    
                }
            }
        }
    }
}
