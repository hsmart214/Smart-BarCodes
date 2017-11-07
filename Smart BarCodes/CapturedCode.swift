//
//  CapturedCode.swift
//  Smart BarCodes
//
//  Created by J. HOWARD SMART on 10/27/17.
//  Copyright © 2017 J. HOWARD SMART. All rights reserved.
//

import Foundation
import AVFoundation

class CapturedCode: Codable{
    let barCodeType : String
    let barCodeValue : String?
    let captureTime : Date
    var descriptor : String?
    
    init(type: String, stringValue : String?, andTime time : Date){
        barCodeType = type
        barCodeValue = stringValue
        captureTime = time
    }
    
    convenience init(metadateObject bc : AVMetadataMachineReadableCodeObject) {
        let isoCode = bc.type.rawValue
        var collector = ""
        for i in isoCode{
            if i.description == "."{
                collector = ""
            }else{
                collector.append(i)
            }
        }
        self.init(type: collector, stringValue: bc.stringValue, andTime: Date())
    }
}
