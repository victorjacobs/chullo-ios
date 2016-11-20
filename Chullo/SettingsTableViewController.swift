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
    
    @IBAction func expireToken(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to expire the token?", message: nil, preferredStyle: .actionSheet)
        let acceptAction = UIAlertAction(title: "Expire", style: .destructive) { action in
            OAuth.expireToken()
            exit(0)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            alert.dismiss(animated: true)
        }
        alert.addAction(acceptAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to logout?", message: nil, preferredStyle: .actionSheet)
        let acceptAction = UIAlertAction(title: "Logout", style: .destructive) { action in
            OAuth.clearToken()
            exit(0)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            alert.dismiss(animated: true)
        }
        alert.addAction(acceptAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Prepare edit controller for segue
        if let identifier = segue.identifier, identifier.hasPrefix("Edit") {
            let settingEditController = segue.destination as! SettingEditTableViewController
            settingEditController.type = SettingEditTableViewControllerType(rawValue: segue.identifier!)
        }
    }
}
