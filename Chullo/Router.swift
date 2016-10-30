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
    case getFiles(Int)
    case getStats
    
    // Upload
    case postFiles(String)
    case uploadFile(String, UIImage)
    
    static var baseUrl: String {
        return "https://chullo.io"
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
            return "/status"
        case .uploadFile(_, _):
            return "/upload"
        }
    }
    
    var method: HTTPMethod {
        switch (self) {
        case .authenticate(_, _), .refreshToken(_), .postFiles(_), .uploadFile(_, _):
            return .post
        default:
            return .get
        }
    }
    
    var url: URL {
        return Foundation.URL(string: Router.baseUrl)!.appendingPathComponent(path)
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .authenticate(_, _), .refreshToken(_):
            return [:]
        default:
            if let accessToken = OAuth.accessToken {
                return [
                    "Authorization": "Bearer \(accessToken)"
                ]
            } else {
                return [:]
            }
        }
    }
    
    var URLRequest: DataRequest {
        //  Set parameters of request
        switch self {
        case .authenticate(let email, let password):
            // TODO constants extracten en ergens storen
            return Alamofire.request(url, method: method, parameters: [
                "grant_type": "password",
                "username": email,
                "password": password,
                "client_id": OAuth.clientId,
                "client_secret": OAuth.clientSecret
                ], encoding: URLEncoding.default)
        case .refreshToken(let refreshToken):
            return Alamofire.request(url, method: method, parameters: [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
                "client_id": OAuth.clientId,
                "client_secret": OAuth.clientSecret
                ], encoding: URLEncoding.default)
        case .postFiles(let fileName):
            return Alamofire.request(url, method: method, parameters: [
                    "name": fileName
                ], encoding: JSONEncoding.default, headers: headers)
        case .getFiles(let page):
            return Alamofire.request(url, method: method, parameters: [
                "page": String(page),
                "page_size": 20
                ], encoding: URLEncoding.default, headers: headers)
        default:
            return Alamofire.request(url, method: method, headers: headers)
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        return self.URLRequest.request!
    }
}
