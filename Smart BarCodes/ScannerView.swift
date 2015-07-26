//
//  ScannerView.swift
//  Smart BarCodes
//
//  Created by J. HOWARD SMART on 7/25/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

import UIKit

class ScannerView: UIView {
    
    weak var delegate : CornerDelegate?

    override func drawRect(rect: CGRect) {
        if let polygons = delegate?.polygons() where polygons.count != 0 {
            // change all of the points from relative space to absolute points
            let h = self.bounds.size.height
            let w = self.bounds.size.width
            var newPolys : [[CGPoint]] = []
            
            for p in polygons{
                var newPoly : [CGPoint] = []
                for pt in p{
                    newPoly.append(CGPoint(x: (1 - pt.y) * w, y: pt.x * h))
                }
                newPolys.append(newPoly)
            }
            
            let context = UIGraphicsGetCurrentContext()
            UIColor.redColor().setStroke()
            let path = UIBezierPath()
            path.lineWidth = 4.0
            
            for poly in newPolys{
                if poly.count == 0 {continue}
                path.moveToPoint(poly[0])
                for pt in poly{
                    path.addLineToPoint(pt)
                }
                path.closePath()
                path.stroke()
                path.removeAllPoints()
            }
        }
    }
}