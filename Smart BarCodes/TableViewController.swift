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
    func capturedBarCodes(_ barCodes : [AVMetadataMachineReadableCodeObject])
}

final class TableViewController: UITableViewController, CaptureDelegate {
    
    fileprivate var barCodes : [AVMetadataMachineReadableCodeObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return barCodes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 

        cell.textLabel?.text = barCodes[(indexPath as NSIndexPath).row].type.rawValue

        return cell
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            barCodes.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - CaptureDelegate
    
    func capturedBarCodes(_ newCodes: [AVMetadataMachineReadableCodeObject]) {
        DispatchQueue.main.async {
            //            self.tableView.beginUpdates()
            for code in newCodes{
                self.barCodes.append(code)
            }
            //            self.tableView.endUpdates()
            self.tableView.reloadData()
        }
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBarCodeDetails"{
            let dest = segue.destination as! BarCodeViewController
            if let cell = sender as? UITableViewCell{
                if let path = self.tableView.indexPath(for: cell){
                    dest.barCode = barCodes[(path as NSIndexPath).row]
                }
            }
        }
        if segue.identifier == "scanForBarcodes"{
            let dest = segue.destination as! ScannerViewController
            dest.delegate = self
        }
    }


}
