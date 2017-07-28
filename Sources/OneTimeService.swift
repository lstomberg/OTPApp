//
//  OneTimeService.swift
//  OneTimePassword (iOS)
//
//  Created by Lucas Stomberg on 7/4/17.
//  Copyright © 2017 Matt Rubin. All rights reserved.
//

import UIKit

class OneTimeService: NSObject {
    public static var next = OneTimeService()
    
//    fileprivate var deviceToken: Data?
    public var webserviceToken: String?
    public var url: URL?
    public var serverIdentifier: String?
    
    func checkRequirementsSatisfied() {
        guard let deviceToken = deviceNotificationToken()?.base64EncodedString(),
            let webserviceToken = webserviceToken,
            let url = url,
            let serverIdentifier = serverIdentifier else {
                return
        }
        
        execute(url, using: webserviceToken, with: ["ServerIdentifier":serverIdentifier,"DeviceToken":deviceToken] as [String:Any])
    }
    
    func execute(_ url: URL, using token: String, with body: [String:Any]) {
        //register with anonymous web service
        guard let url = URL(string: "https://endpoint/httpListener.aspx?") else {
            //alert user bad key
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            print(response!)
            print(error!)
            print(data!)
            
            self.webserviceToken = nil
        }
        task.resume()
    }
}


