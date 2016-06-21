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

class LoginViewController: UIViewController, UITextFieldDelegate {
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self

        getUserProfile()
        getFiles()
    }
    
    func getUserProfile() {
        if let _ = OAuth.accessToken {
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
    
    func getFiles() {
        if let _ = OAuth.accessToken {
            debugPrint(Alamofire.request(Router.GetFiles)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success(let data):
                        print(data)
                    case .Failure(let err):
                        print(err)
                    }
                })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func login(sender: UIButton?) {
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
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
            login(nil)
        default: break
        }
        
        return textField.text?.characters.count > 0
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
