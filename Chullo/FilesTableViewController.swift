//
//  FilesTableViewController.swift
//  Chullo
//
//  Created by Victor Jacobs on 21/06/16.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import UIKit
import Photos
import Alamofire
import SwiftyJSON

// TODO maybe move upload logic to different controller
class FilesTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var files: [File] = []
    var totalRecords: Int?
    var pageSize: Int?
    
    private let apiQueue = DispatchQueue(label: "com.victorjacobs.Chullo.files-table-view-api")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch all files when view will appear (not when loaded, because that might miss first load when logging in)
        if (files.count != 0) {
            return
        }
        
        loadOnePageOfFiles(startingFrom: 0) {}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func upload(_ sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL {
            let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
            //let filename = result.firstObject?.fileName ?? ""
            let filename: String? = "TODO"
            
            // TODO maybe promisify this
            debugPrint(Alamofire.request(Router.postFiles(filename!))
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        self.dismiss(animated: true, completion: nil)
                        let id = JSON(data)["_id"]
                    case .failure(let err):
                        print(err)
                    }
                })
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return totalRecords ?? 0
        return self.files.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileTableViewCell", for: indexPath) as! FileTableViewCell
        
        let index = (indexPath as NSIndexPath).row
        
        if (index >= files.count && index < totalRecords!) {
            print("Loading more rows")
            loadOnePageOfFiles(startingFrom: self.files.count + 1) {
                cell.file = self.files[index]
            }
        } else {
            cell.file = self.files[index]
        }
        
        return cell
    }
    
    private func loadOnePageOfFiles(startingFrom start: Int, onCompletion: @escaping () -> ()) {
        var pageToLoad: Int
        if let pageSize = pageSize {
            pageToLoad = Int(floor(Double(start) / Double(pageSize)))
        } else {
            pageToLoad = 1
        }
        
        Alamofire.request(Router.getFiles(pageToLoad))
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    self.totalRecords = Int(response.response?.allHeaderFields["x-pagination-totalrecords"] as! String)!
                    self.pageSize = Int(response.response?.allHeaderFields["x-pagination-pagesize"] as! String)!
                    print("Got \(self.totalRecords) records with pagesize \(self.pageSize)")
                    
                    let json = JSON(data)
                    for file in json {
                        self.files.append(File(file.1))
                    }
                    
                    self.tableView.reloadData()
                case .failure(let err):
                    print(err)
                }
                
                onCompletion()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFile" {
            let fileViewController = segue.destination as! FileViewController
            if let selectedFileCell = sender as? FileTableViewCell {
                fileViewController.file = selectedFileCell.file
            }
        }
    }

}
