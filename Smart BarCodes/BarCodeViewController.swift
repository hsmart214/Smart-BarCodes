//
//  BarCodeViewController.swift
//  Smart BarCodes
//
//  Created by J. HOWARD SMART on 7/24/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

import UIKit
import AVFoundation

protocol CodeEditDelegate {
    func update(code: CapturedCode)
}

class BarCodeViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var descriptorTextField: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    var barCode : CapturedCode?
    var delegate : CodeEditDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        descriptorTextField.text = barCode?.descriptor
        textView.text = barCode?.barCodeValue
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        barCode?.descriptor = descriptorTextField.text
        textField.resignFirstResponder()
        if let code = barCode{
            delegate?.update(code: code)
        }
        return true
    }
    
    override func viewDidLoad() {
        descriptorTextField.delegate = self
    }

}
