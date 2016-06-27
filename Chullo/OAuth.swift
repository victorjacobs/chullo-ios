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
    
    // MARK: Properties
    static var accessToken: String? {
        if expired, let refreshToken = refreshToken {
            // Use semaphore to perform synchronous token refresh
            let semaphore = dispatch_semaphore_create(0)
            
            // Create queue to avoid refresh token call waiting on call that triggered it
            let queue = dispatch_queue_create("com.victorjacobs.chullo.refresh-token-queue", DISPATCH_QUEUE_CONCURRENT)
            
            debugPrint(Alamofire.request(Router.RefreshToken(refreshToken))
                .validate()
                .responseJSON(queue: queue, options: .AllowFragments) { response in
                    switch response.result {
                    case .Success(let data):
                        saveFromOAuthResponse(data)
                        print("Successfully refreshed token \(data)")
                    case .Failure(let err):
                        print("Failed refreshing token \(err)")
                        clearToken()
                    }
                    
                    dispatch_semaphore_signal(semaphore)
                })
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
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
            // If expiresAt not found, assume that the token was expired
            return true
        }
    }
    
    static var validToken: Bool {
        // Don't try and check whether accessToken is nil because that will start a whole thing
        if let _ = refreshToken {
            return true
        } else {
            return false
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