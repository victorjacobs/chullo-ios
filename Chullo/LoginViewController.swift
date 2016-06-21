//
//  LoginViewController.swift
//  Chullo
//
//  Created by Victor Jacobs on 18/06/16.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getUserProfile()
    }
    
    func getUserProfile() {
        if let accessToken = OAuth.accessToken {
            print(accessToken)
            debugPrint(Alamofire.request(Router.Profile)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success(let data):
                        print(data)
                        let json = JSON(data)
                        self.debugLabel.text = "Welcome \(json["emailAddress"]) (\(json["_id"]))"
                    case .Failure:
                        print(response)
                    }
                })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func login(sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            OAuth.authenticate(email, password: password)
            getUserProfile()
        } else {
            print("invalid credentials")
        }
    }
    
    @IBAction func removeToken(sender: UIButton) {
        OAuth.clearToken()
        exit(1)
    }

    @IBAction func refreshToken(sender: UIButton) {
        OAuth.expireToken()
        OAuth.accessToken
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
