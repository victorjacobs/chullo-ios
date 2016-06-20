//
//  Router.swift
//  Chullo
//
//  Created by Victor Jacobs on 20/06/16.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    // MARK: Enum values
    case Authenticate(String, String)
    
    var baseUrl: String {
        return "https://chullo.io"
    }
    
    var method: Alamofire.Method {
        return .POST
    }
    
    var path: String {
        switch (self) {
        case .Authenticate(_, _):
            return "/oauth/token"
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: baseUrl)!
        var mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch (self) {
        case .Authenticate(let email, let password):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: [
                "grant_type": "password",
                "username": email,
                "password": password,
                "client_id": "CYdRSMq2PGkJdsEd9uhIZFqWS0sYqZ",
                "client_secret": "rTLuyr6OiKksinIMoG8vdW1tGGsWuG"
                ]).0
        }
    }
    
    func setBearerToken(request: NSMutableURLRequest) {
        
    }
}