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
            let url = URL(string: file.downloadUrl)
            
            DispatchQueue.main.async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async(execute: {
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
}
