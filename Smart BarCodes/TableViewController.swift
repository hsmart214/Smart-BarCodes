//
//  TableViewController.swift
//  Smart BarCodes
//
//  Created by J. HOWARD SMART on 7/24/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

import UIKit
import AVFoundation

protocol CaptureDelegate : class {
    func capturedBarCodes(barCodes : [AVMetadataMachineReadableCodeObject])
}

final class TableViewController: UITableViewController, CaptureDelegate {
    
    private var barCodes : [AVMetadataMachineReadableCodeObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return barCodes.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 

        cell.textLabel?.text = barCodes[indexPath.row].type

        return cell
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            barCodes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: - CaptureDelegate
    
    func capturedBarCodes(newCodes: [AVMetadataMachineReadableCodeObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            //            self.tableView.beginUpdates()
            for code in newCodes{
                self.barCodes.append(code)
            }
            //            self.tableView.endUpdates()
            self.tableView.reloadData()
        }
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showBarCodeDetails"{
            let dest = segue.destinationViewController as! BarCodeViewController
            if let cell = sender as? UITableViewCell{
                if let path = self.tableView.indexPathForCell(cell){
                    dest.barCode = barCodes[path.row]
                }
            }
        }
        if segue.identifier == "scanForBarcodes"{
            let dest = segue.destinationViewController as! ScannerViewController
            dest.delegate = self
        }
    }


}
