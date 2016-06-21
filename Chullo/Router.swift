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
    case RefreshToken(String)
    case Profile
    
    var baseUrl: String {
        return "https://chullo.io"
    }
    
    var method: Alamofire.Method {
        switch (self) {
        case .Authenticate(_, _), .RefreshToken(_):
            return .POST
        default:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .Authenticate(_, _), .RefreshToken(_):
            return "/oauth/token"
        case Profile:
            return "/users/me"
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: baseUrl)!
        var mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        // Set authorization
        switch self {
        case .Authenticate(_, _), .RefreshToken(_):
            break
        default:
            if let accessToken = OAuth.accessToken {
                mutableURLRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                print("no accesstoken found")
            }
        }
        
        //  Set parameters of request
        switch self {
        case .Authenticate(let email, let password):
            // TODO constants extracten en ergens storen
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: [
                "grant_type": "password",
                "username": email,
                "password": password,
                "client_id": "CYdRSMq2PGkJdsEd9uhIZFqWS0sYqZ",
                "client_secret": "rTLuyr6OiKksinIMoG8vdW1tGGsWuG"
                ]).0
        case .RefreshToken(let refreshToken):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
                "client_id": "CYdRSMq2PGkJdsEd9uhIZFqWS0sYqZ",
                "client_secret": "rTLuyr6OiKksinIMoG8vdW1tGGsWuG"
                ]).0
        default:
            return mutableURLRequest
        }
    }
}