//
//  SettingsTableViewController.swift
//  Chullo
//
//  Created by Victor Jacobs on 17/10/2016.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var totalFilesLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var builtOnLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var totalTrafficLabel: UILabel!
    @IBOutlet weak var totalSizeLabel: UILabel!
    @IBOutlet weak var clientIdLabel: UILabel!
    @IBOutlet weak var clientSecretLabel: UILabel!
    
    var statusData: JSON? {
        didSet {
            self.totalFilesLabel.text = statusData!["files"].stringValue
            self.versionLabel.text = statusData!["version"].stringValue
            self.builtOnLabel.text = statusData!["builtOn"].stringValue
            self.totalTrafficLabel.text = ByteCountFormatter.string(fromByteCount: statusData!["totalTraffic"].int64Value, countStyle: .decimal)
            self.totalSizeLabel.text = ByteCountFormatter.string(fromByteCount: statusData!["totalSize"].int64Value, countStyle: .decimal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request(Router.getStatus)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    print(data)
                    self.statusData = JSON(data)
                case .failure(let err):
                    print(err)
                }
        }
        
        self.clientIdLabel.text = OAuth.clientId
        self.clientSecretLabel.text = OAuth.clientSecret
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func done(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
