//
//  FileViewController.swift
//  Chullo
//
//  Created by Victor Jacobs on 31/07/16.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import UIKit

class FileViewController: UIViewController {
    // MARK: Properties
    var file: File! {
        didSet {
            let url = NSURL(string: file.downloadUrl)
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: url!)
                dispatch_async(dispatch_get_main_queue(), {
                    if let data = data {
                        self.imageView.image = UIImage(data: data)
                    }
                });
            }
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
