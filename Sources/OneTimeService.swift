//
//  OneTimeService.swift
//  OneTimePassword (iOS)
//
//  Created by Lucas Stomberg on 7/4/17.
//  Copyright © 2017 Matt Rubin. All rights reserved.
//

import UIKit

struct OneTimeService {
   static var temporaryAuthStore = AuthStore()
   let authorizationToken: String
   let serverURL: URL
   var query: [String: Any]

   init(authorizationToken: String, serverURL: URL) {
      self.authorizationToken = authorizationToken
      self.serverURL = serverURL
      self.query = [:]
   }

   func execute(){
      
      var postParameters = query
      postParameters["AuthToken"] = authorizationToken
      postParameters["PlatformID"] = 1 //ios

      guard let jsonData = try? JSONSerialization.data(withJSONObject: postParameters, options: []) else {
         print ("Error serializing post parameters to JSON")
         return
      }

      var postRequest = URLRequest(url: serverURL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 8.0)
      postRequest.httpBody = jsonData
      postRequest.httpMethod = "POST"
      postRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
      postRequest.setValue("application/json", forHTTPHeaderField: "Accept")

      let task = URLSession.shared.dataTask(with: postRequest) { (data, response, error) in
         let dict: [String:Any?] = ["endpoint":self.serverURL, "response":response, "content length":data?.count, "error":error ]

         if let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let dict = json as? Dictionary<String,Any> {
            print ("")
            print ("************")
            print ("* DATA      ")
            print ("************")
            print (dict)
         }

         if let response = response {
            print ("")
            print ("************")
            print ("* RESPONSE  ")
            print ("************")
            print (response)
         }

         if let error = error {
            print ("")
            print ("************")
            print ("* ERROR     ")
            print ("************")
            print (error)
         }

         let alertController = UIAlertController(title: "Task response:", message: "\(dict as AnyObject)", preferredStyle: .alert)
         alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
      }
      task.resume()
   }

   struct AuthStore {
      struct Entry {
         let authorizationToken: String
         let webserviceURL: URL
      }

      var entries: [Entry] = []

      public mutating func add(_ entry: Entry) {
         entries.append(entry)
      }

      fileprivate mutating func pop(entryFor url: URL) -> Entry? {
         guard let index = entries.index(where: { (e) -> Bool in
            e.webserviceURL == url
         }) else {
            return nil
         }

         return entries.remove(at: index)
      }
   }
}

extension OneTimeService {
   private init(_ entry: AuthStore.Entry) {
      self.init(authorizationToken: entry.authorizationToken, serverURL: entry.webserviceURL)
   }

   static func registration(serverURL: URL, serverGUID: String, pushNotificationToken: String) -> OneTimeService? {
      guard let entry = temporaryAuthStore.pop(entryFor: serverURL) else {
         return nil
      }

      var service = OneTimeService(entry)
      service.query = ["EnvironmentGUID":serverGUID,"DeviceToken":pushNotificationToken,"Passcode":1]
      return service
   }

   enum Response : String {
      case accept = "1"
      case decline = "0"
   }

   static func response(serverURL: URL, response: Response) -> OneTimeService? {
      guard let entry = temporaryAuthStore.pop(entryFor: serverURL) else {
         return nil
      }

      var service = OneTimeService(entry)
      service.query = ["response":response]
      return service
   }
}




