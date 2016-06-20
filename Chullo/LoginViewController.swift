//
//  LoginViewController.swift
//  Chullo
//
//  Created by Victor Jacobs on 18/06/16.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func login(sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            debugPrint(Alamofire.request(Router.Authenticate(email, password))
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        print(response)
                        
                    case .Failure:
                        print("invalid credentials")
                        print(response)
                    }
                })
        } else {
            print("invalid credentials")
        }
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
