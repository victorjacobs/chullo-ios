//
//  Oauth.swift
//  Chullo
//
//  Created by Victor Jacobs on 20/06/16.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import Alamofire
import SwiftyJSON

class OAuth {
    var token: String {
        return "test"
    }
    
    static func saveFromOAuthResponse(response: AnyObject) {
        let json = JSON(response)
        let token = json["access_token"].stringValue
        let refreshToken = json["refresh_token"].stringValue
        let expiresAt = NSDate().dateByAddingSeconds(100)
    }
}