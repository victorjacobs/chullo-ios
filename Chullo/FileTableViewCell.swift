//
//  FileTableViewCell.swift
//  Chullo
//
//  Created by Victor Jacobs on 21/06/16.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import UIKit

class FileTableViewCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var filenameLabel: UILabel!
    var file: File! {
        didSet {
            filenameLabel.text = file.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
