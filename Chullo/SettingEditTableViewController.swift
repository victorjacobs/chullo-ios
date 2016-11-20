//
//  SettingEditTableViewController.swift
//  Chullo
//
//  Created by Victor Jacobs on 20/11/2016.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import UIKit

enum SettingEditTableViewControllerType: String {
    case clientId = "EditClientID"
    case clientSecret = "EditClientSecret"
}

class SettingEditTableViewController: UITableViewController {
    @IBOutlet weak var valueTextField: UITextField!
    
    
    var type: SettingEditTableViewControllerType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch type! {
        case .clientId:
            setupControllerForClientID()
        case .clientSecret:
            setupControllerForClientSecret()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupControllerForClientID() {
        title = "Client ID"
        valueTextField.placeholder = "Client ID"
        valueTextField.text = OAuth.clientId
    }
    
    private func setupControllerForClientSecret() {
        title = "Client Secret"
        valueTextField.placeholder = "Client Secret"
        valueTextField.text = OAuth.clientSecret
    }
}
