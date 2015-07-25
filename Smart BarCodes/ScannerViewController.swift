//
//  ScannerViewController.swift
//  Smart BarCodes
//
//  Created by J. HOWARD SMART on 7/24/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var delegate : CaptureDelegate?
    var lastRecognizedObject : AVMetadataMachineReadableCodeObject?
    var captureSession : AVCaptureSession!
    var captureDevice : AVCaptureDevice!
    var pLayer : AVCaptureVideoPreviewLayer?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        captureSession = AVCaptureSession()
        
        var error : NSError? = nil
        var videoInput = AVCaptureDeviceInput(device: captureDevice, error: &error)
        if videoInput != nil{
            captureSession.addInput(videoInput!)
        }else{
            println(error?.debugDescription)
        }
        
        var metaDataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metaDataOutput)
        
        metaDataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
        
        let barCodeTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeDataMatrixCode]
        // print(metaDataOutput.availableMetadataObjectTypes)
        metaDataOutput.metadataObjectTypes = barCodeTypes
        
        
        
        pLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        pLayer?.frame = self.view.layer.bounds
        
        self.view.layer.addSublayer(pLayer)
        
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
        pLayer?.removeFromSuperlayer()
    }
    
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if self.captureSession.running {
            let x = metadataObjects.count
            if let firstObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject{
                if firstObject.stringValue == lastRecognizedObject?.stringValue {
                    return
                }else{
                    lastRecognizedObject = firstObject
                    println("Identified \(x) readable object(s)")
                    if let objects = metadataObjects as? [AVMetadataMachineReadableCodeObject]{
                        delegate?.capturedBarCodes(objects)
                    }
                    dispatch_async(dispatch_get_main_queue()){
                        self.captureSession.stopRunning()
                        self.pLayer?.removeFromSuperlayer()
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
            }
        }
    }
    
    // MARK - Gesture recognizers

    @IBAction func tap(sender: UITapGestureRecognizer) {
        let pt = sender.locationInView(self.view)
        captureDevice.lockForConfiguration(nil)
        captureDevice.focusPointOfInterest = pt
        captureDevice.unlockForConfiguration()
    }
    
    @IBAction func pinch(sender: UIPinchGestureRecognizer) {
        let factor = sender.scale
        sender.scale = 1.0
        let zoom = captureDevice.videoZoomFactor
        let max = captureDevice.activeFormat.videoMaxZoomFactor
        var newZoom = factor * zoom
        newZoom = min(max, newZoom)
        if newZoom < 1.0 {newZoom = 1.0}
        
        captureDevice.lockForConfiguration(nil)
        captureDevice.videoZoomFactor = newZoom
        captureDevice.unlockForConfiguration()
    }
}
