//
//  File.swift
//  Chullo
//
//  Created by Victor Jacobs on 21/06/16.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import Foundation
import SwiftyJSON

class File {
    let name: String
    let id: String
    let type: String?
    let size: Int
    let updatedAt: Date
    var viewUrl: String {
        return "\(Router.baseUrl)/v/\(id)"
    }
    var downloadUrl: String {
        return "\(Router.baseUrl)/d/\(id)"
    }
    var thumbnailUrl: String {
        return "\(viewUrl)/thumb"
    }
    var thumbnail: UIImage?
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        id = json["_id"].stringValue
        type = json["mime"].stringValue
        size = json["size"].intValue
        updatedAt = Date(fromString: json["updatedAt"].stringValue, format: .iso8601(.DateTimeMilliSec))
        
        let thumbnailQueue = DispatchQueue(label: "com.victorjacobs.Chullo.thumbail-fetcher", attributes: .concurrent)
        
        // TODO make the next thing even more lazy (should only be loaded when the file comes into view)
        thumbnailQueue.async {
            if let url = try? self.thumbnailUrl.asURL(), let imageData = try? Data(contentsOf: url) {
                print("Downloading thumbnail")
                self.thumbnail = UIImage(data: imageData)
            }
        }
    }
}
