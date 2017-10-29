//
//  CapturedCodeTableViewCell.swift
//  Smart Barcodes
//
//  Created by J. HOWARD SMART on 10/28/17.
//  Copyright © 2017 J. HOWARD SMART. All rights reserved.
//

import UIKit

class CapturedCodeTableViewCell: UITableViewCell {

    var df : DateFormatter?
    var code : CapturedCode?{
        didSet{
            updateUI()
        }
    }
    
    @IBOutlet weak var descriptor: UILabel!
    @IBOutlet weak var encodingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    func updateUI(){
        descriptor.text = code?.descriptor ?? NSLocalizedString("New scanned barcode", comment: "New code")
        encodingLabel.text = code?.barCodeType
        df?.timeStyle = .none
        df?.dateStyle = .short
        if code != nil{
            dateLabel.text = df?.string(from: code!.captureTime)
        }else{
            dateLabel.text = nil
        }
        contentTextView.text = code?.barCodeValue
        contentTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        contentTextView.flashScrollIndicators()
    }
    
    override func awakeFromNib() {
        updateUI()
    }
    
    override func prepareForReuse() {
        updateUI()
    }
    
}
