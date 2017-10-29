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

final class TableViewController: UITableViewController, CaptureDelegate, CodeEditDelegate {
    
    struct DayOfCodes : Codable{
        var date : Date
        var codes = [CapturedCode]()
    }
    
    let filename = "SmartBarCodes.json"
    var barCodes = [DayOfCodes]()
    var df = DateFormatter()
    var observerToken : Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        df.dateStyle = .short
        df.timeStyle = .short
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        if !unarchive(){
            barCodes = []
        }
        observerToken = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil) {
            [unowned self](notification) in
            self.archive()
            NotificationCenter.default.removeObserver(self.observerToken!)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - UITableViewDatasource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return barCodes.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return barCodes[section].codes.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if barCodes.count == 0 {return nil}
        var view : UILabel? = nil
        df.dateStyle = .medium
        df.timeStyle = .none
        if let text = df.string(for:barCodes[section].date){
            view = UILabel(frame: CGRect.zero)
            view?.text = text
            view?.textColor = UIColor.white
            view?.backgroundColor = UIColor.clear
            view?.font = UIFont.preferredFont(forTextStyle: .callout)
            view?.textAlignment = .center
            view?.sizeToFit()
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let view = tableView.headerView(forSection: section){
            return view.intrinsicContentSize.height
        }
        return 44
    }

//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        df.dateStyle = .medium
//        df.timeStyle = .none
//        if barCodes.count == 0 {return nil}
//        return df.string(for:barCodes[section].date)
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CapturedCodeTableViewCell
        cell.df = df
        cell.code = barCodes[indexPath.section].codes[indexPath.row]
        
        return cell
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            barCodes[indexPath.section].codes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - CaptureDelegate
    
    func capturedBarCodes(_ newCodes: [AVMetadataMachineReadableCodeObject]) {
        var section : Int
        let today = Date()
        if barCodes.count == 0{
            // this is the first day of codes, add a day and start using it
            barCodes.append(DayOfCodes(date: today, codes: []))
            section = 0
        }else{
            df.timeStyle = .none
            df.dateStyle = .medium
            let todaysDate = df.string(from: today)
            if df.string(from:barCodes.last!.date) == todaysDate{
                // this means we are appending codes to an existing day of codes
                section = barCodes.count - 1
            }else{
                // we need to add a new day to the end of the list of days
                section = barCodes.count
                barCodes.append(DayOfCodes(date: today, codes: []))
            }
        }
        DispatchQueue.main.async {[weak self] in
            //            self.tableView.beginUpdates()
            for code in newCodes{
                self?.barCodes[section].codes.append(CapturedCode(metadateObject: code))
            }
            //            self.tableView.endUpdates()
            self?.tableView.reloadData()
            DispatchQueue.global(qos: .userInitiated).async {
                self?.archive()
            }
        }
    }

    // MARK: - CodeEditDelegate
    
    func update(code : CapturedCode){
        archive()
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBarCodeDetails"{
            let dest = segue.destination as! BarCodeViewController
            if let cell = sender as? UITableViewCell{
                if let path = self.tableView.indexPath(for: cell){
                    dest.barCode = barCodes[path.section].codes[path.row]
                }
            }
        }
        if segue.identifier == "scanForBarcodes"{
            let nav = segue.destination as! UINavigationController
            let dest = nav.viewControllers.first as! ScannerViewController
            dest.delegate = self
        }
    }
    
    // MARK: - Persistence of Barcodes
    
    func archive(){
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(barCodes){
            try? jsonData.write(to: archiveURL())
        }
    }

    func unarchive() -> Bool{
        let url = archiveURL()
        let decoder = JSONDecoder()
        
        if let jsonData =  try? Data(contentsOf: url), let archive = try? decoder.decode([DayOfCodes].self, from: jsonData){
            barCodes = archive
            //Swift.print("Successfully read archive.")
            return true
        }else{
            //Swift.print("Unsucessful read from archive.")
            return false
        }
    }
    
    func archiveURL() -> URL{
        let searchPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentPath = searchPaths.first! as NSString
        return URL(fileURLWithPath: documentPath.appendingPathComponent(filename))
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tableView.reloadData()
//    }
    
    
}
