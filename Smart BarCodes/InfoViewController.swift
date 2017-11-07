//
//  InfoViewController.swift
//  Smart Barcodes
//
//  Created by J. HOWARD SMART on 11/5/17.
//  Copyright © 2017 J. HOWARD SMART. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBAction func done(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
