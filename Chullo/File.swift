//
//  File.swift
//  Chullo
//
//  Created by Victor Jacobs on 21/06/16.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ThumbnailImage {
    case notLoaded
    case loaded(UIImage)
    case noThumbnail
}

class File {
    let name: String
    let id: String
    let type: String?
    let size: Int
    let updatedAt: Date
    var thumbnail: ThumbnailImage = .notLoaded
    var viewUrl: String {
        return "\(Router.baseUrl)/v/\(id)"
    }
    var downloadUrl: String {
        return "\(Router.baseUrl)/d/\(id)"
    }
    var thumbnailUrl: String {
        return "\(viewUrl)/thumb"
    }
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        id = json["_id"].stringValue
        type = json["mime"].stringValue
        size = json["size"].intValue
        updatedAt = Date(fromString: json["updatedAt"].stringValue, format: .iso8601(.DateTimeMilliSec))
    }
    
    func loadThumbnail() {
        if let url = try? self.thumbnailUrl.asURL(), let imageData = try? Data(contentsOf: url) {
            print("Downloading thumbnail")
            
            if let loadedThumbnail = UIImage(data: imageData) {
                self.thumbnail = .loaded(loadedThumbnail)
            } else {
                self.thumbnail = .noThumbnail
            }
        } else {
            self.thumbnail = .noThumbnail
        }
    }
}
