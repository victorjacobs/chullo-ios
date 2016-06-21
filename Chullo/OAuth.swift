//
//  Oauth.swift
//  Chullo
//
//  Created by Victor Jacobs on 20/06/16.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import AFDateHelper

class OAuth {
    // TODO move accesstoken aanvragen naar hier
    // MARK: Storage Keys
    static let tokenKey = "oauthToken"
    static let tokenExpiryKey = "oauthTokenExpiry"
    static let refreshTokenKey = "oauthRefreshTokenKey"
    static let defaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: Fields
    static var accessToken: String? {
        if expired, let refreshToken = refreshToken {
            debugPrint(Alamofire.request(Router.RefreshToken(refreshToken))
                .validate()
                .responseJSON { request in
                    switch request.result {
                    case .Success(let data):
                        saveFromOAuthResponse(data)
                        print("Successfully refreshed token \(data)")
                    case .Failure(let err):
                        print("Failed refreshing token \(err)")
                        clearToken()
                    }
                })
        }
        return defaults.objectForKey(tokenKey) as? String
    }
    
    static var refreshToken: String? {
        return defaults.objectForKey(refreshTokenKey) as? String
    }
    
    static var expired: Bool {
        if let expiresAt = defaults.objectForKey(tokenExpiryKey) as? NSDate {
            return expiresAt.isInPast()
        } else {
            return true
        }
    }
    
    // MARK: OAuth Methods
    static func authenticate(userName: String, password: String) {
        debugPrint(Alamofire.request(Router.Authenticate(userName, password))
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    print(response)
                    saveFromOAuthResponse(value)
                case .Failure:
                    print("invalid credentials")
                    print(response)
                }
            })
    }
    
    static func saveFromOAuthResponse(response: AnyObject) {
        let json = JSON(response)
        let token = json["access_token"].stringValue
        let refreshToken = json["refresh_token"].stringValue
        let expiresAt = NSDate().dateByAddingSeconds(json["expires_in"].intValue)
        
        defaults.setObject(token, forKey: tokenKey)
        defaults.setObject(refreshToken, forKey: refreshTokenKey)
        defaults.setObject(expiresAt, forKey: tokenExpiryKey)
        
        print("saved token \(token)")
    }
    
    // MARK: Debug Methods
    static func clearToken() {
        defaults.removeObjectForKey(tokenKey)
        defaults.removeObjectForKey(tokenExpiryKey)
        defaults.removeObjectForKey(refreshTokenKey)
        
        print("token removed")
    }
    
    static func expireToken() {
        defaults.setObject(NSDate().dateBySubtractingDays(10), forKey: tokenExpiryKey)
        print("token expired")
    }
}