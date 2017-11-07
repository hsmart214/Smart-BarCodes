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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureDevice = AVCaptureDevice.default(for: .video)
        captureSession = AVCaptureSession()
        
        var error : NSError? = nil
        var videoInput: AVCaptureDeviceInput!
        do {
            videoInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error1 as NSError {
            error = error1
            videoInput = nil
        }
        if videoInput != nil{
            captureSession.addInput(videoInput!)
        }else{
            print(error!.debugDescription)
        }
        
        let metaDataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metaDataOutput)
        
        metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated))
        
        //let barCodeTypes = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.upce, AVMetadataObject.ObjectType.code39, AVMetadataObject.ObjectType.code39Mod43, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.code93, AVMetadataObject.ObjectType.code128, AVMetadataObject.ObjectType.pdf417, AVMetadataObject.ObjectType.aztec, AVMetadataObject.ObjectType.dataMatrix]
        //let barCodeTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeDataMatrixCode]
        let barCodeTypes : [AVMetadataObject.ObjectType] = [.qr, .ean8, .ean13, .upce, .code39, .code39Mod43, .code93, .code128, .pdf417, .aztec, .dataMatrix, .itf14, .interleaved2of5]
        metaDataOutput.metadataObjectTypes = barCodeTypes
        
        
        
        pLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        pLayer?.frame = self.view.layer.bounds
        
        self.previewView.layer.addSublayer(pLayer!)
        pLayer?.zPosition = -1.0
        
        
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if self.captureSession.isRunning {
            let x = metadataObjects.count
            if x == 0 { return }
            if let firstObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject{
                if firstObject.stringValue == lastRecognizedObject?.stringValue {
                    return
                }else{

                    lastRecognizedObject = firstObject
                    if let objects = metadataObjects as? [AVMetadataMachineReadableCodeObject]{
                        delegate?.capturedBarCodes(objects)
                        var newPolys : [[CGPoint]] = []
                        for object in objects{
                            if object.corners.count != 0 { newPolys.append(object.corners) }
                        }
                        DispatchQueue.main.async {
                            [unowned self] in
                            self.polys = newPolys
                            //self.doneButton(self)
                            self.perform(#selector(self.doneButton(_:)), with: self, afterDelay: 2.5)
                        }
                    }
                }
            }
        }
    }

    // MARK - Gesture recognizers

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        let pt = sender.location(in: self.view)
        let focalPoint = CGPoint(x: pt.y / self.view.bounds.height, y: (self.view.bounds.width - pt.x) / self.view.bounds.width)
        do {
            try captureDevice.lockForConfiguration()
        } catch _ {
        }
        captureDevice.focusPointOfInterest = focalPoint
        captureDevice.unlockForConfiguration()
    }
    
    @IBAction func pinch(_ sender: UIPinchGestureRecognizer) {
        let factor = sender.scale
        sender.scale = 1.0
        let zoom = captureDevice.videoZoomFactor
        let max = captureDevice.activeFormat.videoMaxZoomFactor
        var newZoom = factor * zoom
        newZoom = min(max, newZoom)
        if newZoom < 1.0 {newZoom = 1.0}
        
        do {
            try captureDevice.lockForConfiguration()
        } catch _ {
        }
        captureDevice.videoZoomFactor = newZoom
        captureDevice.unlockForConfiguration()
    }
    
    
    @IBAction func doneButton(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
