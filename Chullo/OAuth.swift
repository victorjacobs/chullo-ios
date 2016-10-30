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
    
    static let queue = DispatchQueue(label: "com.victorjacobs.Chullo.oauth-queue", attributes: .concurrent)
    
    // MARK: Properties
    static var accessToken: String? {
        if expired, let refreshToken = refreshToken {
            // Use semaphore to perform synchronous token refresh
            let semaphore = DispatchSemaphore(value: 0)
            
            debugPrint(Alamofire.request(Router.refreshToken(refreshToken))
                .validate()
                .responseJSON(queue: queue, options: .allowFragments) { response in
                    switch response.result {
                    case .success(let data):
                        saveFromOAuthResponse(data)
                        print("Successfully refreshed token \(data)")
                    case .failure(let err):
                        print("Failed refreshing token \(err)")
                        clearToken()
                    }
                    
                    semaphore.signal()
                })
            
            let _ = semaphore.wait(timeout: .distantFuture)
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
        // Block main thread while getting token
        let semaphore = DispatchSemaphore(value: 0)
        
        Alamofire.request(Router.authenticate(userName, password))
            .validate()
            .responseJSON(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    saveFromOAuthResponse(value)
                case .failure:
                    print("invalid credentials")
                    print(response)
                }
                
                semaphore.signal()
            }
        
        let _ = semaphore.wait(timeout: .distantFuture)
    }
    
    static func saveFromOAuthResponse(_ response: Any) {
        let json = JSON(response)
        let token = json["access_token"].stringValue
        let refreshToken = json["refresh_token"].stringValue
        let expiresAt = Date().dateByAddingSeconds(json["expires_in"].intValue)
        
        defaults.set(token, forKey: tokenKey)
        defaults.set(refreshToken, forKey: refreshTokenKey)
        defaults.set(expiresAt, forKey: tokenExpiryKey)
        
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
        defaults.set(Date().dateBySubtractingDays(10), forKey: tokenExpiryKey)
        print("token expired")
    }
}
