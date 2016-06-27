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
import OnePasswordExtension

class LoginViewController: UIViewController, UITextFieldDelegate {
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var onepasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Programatically set 1password image because interfacebuilder ¯\_(ツ)_/¯
        let bundle = NSBundle(path: NSBundle(forClass: OnePasswordExtension.self).pathForResource("OnePasswordExtensionResources", ofType: "bundle")!)
        let image = UIImage(named: "onepassword-button.png", inBundle: bundle, compatibleWithTraitCollection: nil)
        onepasswordButton.setImage(image, forState: .Normal)
        // Hide when 1password not available
        onepasswordButton.hidden = !OnePasswordExtension.sharedExtension().isAppExtensionAvailable()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func login(sender: UIButton?) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            // TODO do something here when not able to log in (do something magic with auth method)
            OAuth.authenticate(email, password: password)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func findLoginFrom1Password(sender: UIButton) {
        OnePasswordExtension.sharedExtension().findLoginForURLString("https://chullo.io", forViewController: self, sender: sender) { (dict, err) in
            if let dict = dict {
                if dict.isEmpty {
                    return
                }
                
                self.emailTextField.text = dict[AppExtensionUsernameKey] as? String
                self.passwordTextField.text = dict[AppExtensionPasswordKey] as? String
            }
        }
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
