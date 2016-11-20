//
//  ProfileViewController.swift
//  Chullo
//
//  Created by Victor Jacobs on 21/06/16.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProfileViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var statsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        debugPrint(Alamofire.request(Router.getStatus)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    print(data)
                    let json = JSON(data)
                    self.statsLabel.text = "Serving \(json["files"]) files"
                case .failure(let err):
                    print(err)
                }
            })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func logout(_ sender: AnyObject) {
        OAuth.clearToken()
    }
    
    @IBAction func expireToken(_ sender: AnyObject) {
        OAuth.expireToken()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
