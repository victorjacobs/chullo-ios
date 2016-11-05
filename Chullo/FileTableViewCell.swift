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
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var filenameLabel: UILabel!
    var file: File! {
        didSet {
            filenameLabel.text = file.name
            switch file.thumbnail {
            case .loaded(let thumbNailImage):
                thumbnailImageView.image = thumbNailImage
            // TODO placeholder image
            default:
                thumbnailImageView.image = nil
            }
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
