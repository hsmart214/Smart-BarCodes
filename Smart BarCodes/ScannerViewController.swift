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

protocol CornerDelegate : class{
    func polygons() -> [[CGPoint]]
}

final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, CornerDelegate {

    weak var delegate : CaptureDelegate?
    var lastRecognizedObject : AVMetadataMachineReadableCodeObject?
    var captureSession : AVCaptureSession!
    var captureDevice : AVCaptureDevice!
    
    @IBOutlet weak var overlayView: ScannerView!

    @IBOutlet weak var previewView: UIView!
    
    var pLayer : AVCaptureVideoPreviewLayer?
    
    // only mutate polys on the main thread - it is accessed in a drawRect
    var polys : [[CGPoint]] = [] {
        didSet {
            self.overlayView.setNeedsDisplay()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overlayView.delegate = self
    }

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
        //let barCodeTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeDataMatrixCode]
        metaDataOutput.metadataObjectTypes = barCodeTypes
        
        
        
        pLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        pLayer?.frame = self.view.layer.bounds
        
        self.previewView.layer.addSublayer(pLayer)
        pLayer?.zPosition = -1.0
        
        
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
        pLayer?.removeFromSuperlayer()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pLayer?.frame = self.view.bounds
    }
    // MARK: - delegate methods
    
    func polygons() -> [[CGPoint]] {
        return polys
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if self.captureSession.running {
            let x = metadataObjects.count
            if x == 0 { return }
            if let firstObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject{
                if firstObject.stringValue == lastRecognizedObject?.stringValue {
                    return
                }else{
                    
                    lastRecognizedObject = firstObject
                    println("Identified \(x) readable object(s)")
                    if let objects = metadataObjects as? [AVMetadataMachineReadableCodeObject]{
                        delegate?.capturedBarCodes(objects)
                        var newPolys : [[CGPoint]] = []
                        for object in objects{
                            var points = [CGPoint]()
                            for corner in object.corners{
                                var point = CGPoint()
                                let cRef = corner as! CFDictionaryRef
                                CGPointMakeWithDictionaryRepresentation(cRef, &point)
                                points.append(point)
                            }
                            if points.count != 0 { newPolys.append(points) }
                        }
                        dispatch_async(dispatch_get_main_queue()) { self.polys = newPolys }
                    }
//                    dispatch_async(dispatch_get_main_queue()){
//                        self.captureSession.stopRunning()
//                        self.pLayer?.removeFromSuperlayer()
//                        self.navigationController?.popViewControllerAnimated(true)
//                    }
                }
            }
        }
    }
    
    // MARK - Gesture recognizers

    @IBAction func tap(sender: UITapGestureRecognizer) {
        let pt = sender.locationInView(self.view)
        let focalPoint = CGPoint(x: pt.y / self.view.bounds.height, y: (self.view.bounds.width - pt.x) / self.view.bounds.width)
        captureDevice.lockForConfiguration(nil)
        captureDevice.focusPointOfInterest = focalPoint
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
