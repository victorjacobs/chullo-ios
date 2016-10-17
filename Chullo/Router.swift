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
    case authenticate(String, String)
    case refreshToken(String)
    case getProfile
    case getFiles
    case getStats
    
    // Upload
    case postFiles(String)
    case uploadFile(String, UIImage)
    
    static var baseUrl: String {
        return "https://chullo.io"
    }
    
    var method: Alamofire.Method {
        switch (self) {
        case .authenticate(_, _), .refreshToken(_), .postFiles(_), .UploadFile(_, _):
            return .POST
        default:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .authenticate(_, _), .refreshToken(_):
            return "/oauth/token"
        case .getProfile:
            return "/users/me"
        case .getFiles, .postFiles(_):
            return "/files"
        case .getStats:
            return "/stats"
        case .UploadFile(_, _):
            return "/upload"
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let URL = Foundation.URL(string: Router.baseUrl)!
        var mutableURLRequest = NSMutableURLRequest(url: URL.appendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        // Set authorization
        switch self {
        case .authenticate(_, _), .refreshToken(_):
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
        case .authenticate(let email, let password):
            // TODO constants extracten en ergens storen
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: [
                "grant_type": "password",
                "username": email,
                "password": password,
                "client_id": "CYdRSMq2PGkJdsEd9uhIZFqWS0sYqZ",
                "client_secret": "rTLuyr6OiKksinIMoG8vdW1tGGsWuG"
//                "client_id": "foo",
//                "client_secret": "bar"
                ]).0
        case .refreshToken(let refreshToken):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
                "client_id": "CYdRSMq2PGkJdsEd9uhIZFqWS0sYqZ",
                "client_secret": "rTLuyr6OiKksinIMoG8vdW1tGGsWuG"
//                "client_id": "foo",
//                "client_secret": "bar"
                ]).0
        case .postFiles(let fileName):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: [
                    "name": fileName
                ]).0
        case .UploadFile(let id, let image):
            return mutableURLRequest
        default:
            return mutableURLRequest
        }
    }
}
