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
   var query: String?

   init(authorizationToken: String, serverURL: URL) {
      self.authorizationToken = authorizationToken
      self.serverURL = serverURL
   }

   func execute(){
      var urlComponents = URLComponents(url: serverURL, resolvingAgainstBaseURL: false)
      urlComponents?.query = "authToken=\(authorizationToken)" + (query != nil ? ("&&\(query!)") : "")
      guard let endpoint = urlComponents?.url else { return }

      let task = URLSession.shared.dataTask(with: endpoint) { (data, response, error) in
         let dict: [String:Any] = ["endpoint":endpoint, "response":response, "data":data, "error":error ]
         print ("Task finished: \(dict as AnyObject)")
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
      service.query = "serverGUID=\(serverGUID)&&pushNotificationToken=\(pushNotificationToken)"
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
      service.query = "response=\(response)"
      return service
   }
}




