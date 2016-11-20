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
class FilesTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchResultsUpdating {
    let searchController = UISearchController(searchResultsController: nil)
    
    var files: [File] = []
    var loading = false
    
    var totalPages: Int?
    var totalRecords: Int?
    var currentPage: Int = 0
    
    private let thumbnailQueue = DispatchQueue(label: "com.victorjacobs.Chullo.thumbnail-fetcher", attributes: .concurrent)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch all files when view will appear (not when loaded, because that might miss first load when logging in)
        if (files.count != 0) {
            return
        }
        
        loadNextPage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup search controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar

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
        if totalRecords == nil || files.count >= totalRecords! {
            return self.files.count
        } else {
            return (self.files.count > 0 ? self.files.count + 1 : 0)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = (indexPath as NSIndexPath).row
        if index < self.files.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileTableViewCell", for: indexPath) as! FileTableViewCell
            
            cell.file = self.files[index]
            
            // Load image whenever cell is loaded
            if case .notLoaded = cell.file.thumbnail {
                thumbnailQueue.async {
                    cell.file.loadThumbnail()
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
            
            cell.textLabel!.text = "Loading..."
            
            return cell
        }
    }
    
    private func loadNextPage() {
        if self.loading {
            return
        }
        
        if let totalPages = self.totalPages, self.currentPage >= totalPages {
            return
        }
        
        self.loading = true
        self.currentPage += 1
        
        Alamofire.request(Router.getFiles(self.currentPage))
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    self.totalPages = Int(response.response?.allHeaderFields["x-pagination-totalpages"] as! String)!
                    self.totalRecords = Int(response.response?.allHeaderFields["x-pagination-totalrecords"] as! String)!
                    
                    print("Got \(self.totalRecords), on page \(self.currentPage)")
                    
                    let json = JSON(data)
                    var rows = [IndexPath]()
                    for file in json {
                        self.files.append(File(file.1))
                        rows.append(IndexPath(row: self.files.count - 1, section: 0))
                    }
                    
//                    self.tableView.insertRows(at: rows, with: .automatic)
                    self.tableView.reloadData()
                    self.loading = false
                case .failure(let err):
                    print(err)
                    self.loading = false
                }
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
    
    // MARK: - Scroll view delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.tableView.contentOffset.y > self.tableView.contentSize.height - self.tableView.bounds.size.height - self.tableView.rowHeight) {
            print("Loading more rows")
            loadNextPage()
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFile" {
            let fileViewController = segue.destination as! FileViewController
            if let selectedFileCell = sender as? FileTableViewCell {
                fileViewController.file = selectedFileCell.file
            }
        }
    }
    
    // MARK: - Search
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }

}
