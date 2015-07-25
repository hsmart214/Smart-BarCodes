//
//  BarCodeViewController.swift
//  Smart BarCodes
//
//  Created by J. HOWARD SMART on 7/24/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

import UIKit
import AVFoundation

class BarCodeViewController: UIViewController {
    
    @IBOutlet weak var barCodeTypeLabel: UILabel!
    
    @IBOutlet weak var barCodeContentsLabel: UILabel!
    
    internal var barCode : AVMetadataMachineReadableCodeObject?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        barCodeTypeLabel.text = barCode?.type
        barCodeContentsLabel.text = barCode?.stringValue
    }

}
