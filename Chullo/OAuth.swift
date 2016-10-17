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
    static let defaults = UserDefaults.standard
    
    // MARK: Properties
    static var accessToken: String? {
        if expired, let refreshToken = refreshToken {
            // Use semaphore to perform synchronous token refresh
            let semaphore = DispatchSemaphore(value: 0)
            
            // Create queue to avoid refresh token call waiting on call that triggered it
            let queue = DispatchQueue(label: "com.victorjacobs.chullo.refresh-token-queue", attributes: DispatchQueue.Attributes.concurrent)
            
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
            
            semaphore.wait(timeout: DispatchTime.distantFuture)
        }
        return defaults.object(forKey: tokenKey) as? String
    }
    
    static var refreshToken: String? {
        return defaults.object(forKey: refreshTokenKey) as? String
    }
    
    static var expired: Bool {
        if let expiresAt = defaults.object(forKey: tokenExpiryKey) as? Date {
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
    static func authenticate(_ userName: String, password: String) {
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
    
    static func saveFromOAuthResponse(_ response: AnyObject) {
        let json = JSON(response)
        let token = json["access_token"].stringValue
        let refreshToken = json["refresh_token"].stringValue
        let expiresAt = Date().dateByAddingSeconds(json["expires_in"].intValue)
        
        defaults.setObject(token, forKey: tokenKey)
        defaults.setObject(refreshToken, forKey: refreshTokenKey)
        defaults.setObject(expiresAt, forKey: tokenExpiryKey)
        
        print("saved token \(token)")
    }
    
    // MARK: Debug Methods
    static func clearToken() {
        defaults.removeObject(forKey: tokenKey)
        defaults.removeObject(forKey: tokenExpiryKey)
        defaults.removeObject(forKey: refreshTokenKey)
        
        print("token removed")
    }
    
    static func expireToken() {
        defaults.setObject(Date().dateBySubtractingDays(10), forKey: tokenExpiryKey)
        print("token expired")
    }
}
