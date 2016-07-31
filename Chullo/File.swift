//
//  File.swift
//  Chullo
//
//  Created by Victor Jacobs on 21/06/16.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import Foundation
import SwiftyJSON

struct File {
    let name: String
    let id: String
    let type: String?
    let size: Int
    let updatedAt: NSDate
    var viewUrl: String {
        return "\(Router.baseUrl)/v/\(id)"
    }
    var downloadUrl: String {
        return "\(Router.baseUrl)/d/\(id)"
    }
    
    static func fromJSON(json: JSON) -> File {
        let parsed = File(name: json["name"].stringValue,
                          id: json["_id"].stringValue,
                          type: json["mime"].stringValue,
                          size: json["size"].intValue,
                          updatedAt: NSDate(fromString: json["updatedAt"].stringValue, format: .ISO8601(.DateTimeMilliSec)))

        return parsed
    }
}