//
//  RequestExtension.swift
//  Chullo
//
//  Created by Victor Jacobs on 27/06/16.
//  Copyright © 2016 Victor Jacobs. All rights reserved.
//

import Foundation
import Alamofire

extension Request {
    public func responseSerial(_ completionHandler: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Void) -> Self {
        let queue = dispatch_queue_create("com.victorjacobs.chullo.alamofire-queue", DISPATCH_QUEUE_SERIAL)
        return self.response(queue: queue, completionHandler: completionHandler)
    }
}
