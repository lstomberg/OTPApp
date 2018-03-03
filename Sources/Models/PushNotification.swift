//
//  PushNotification.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 3/3/18.
//  Copyright © 2018 Epic. All rights reserved.
//

import Foundation

struct PushNotification : Codable {
   var oAuth2Token: String
   var environmentGUID : String
   var acknowledgeURLString : String? //are we sending this?
   var alert: Alert

   struct Alert : Codable {
      var title: String
      var message: String
   }
}

extension PushNotification {
   func ackURL() -> URL? {
      guard let urlString = acknowledgeURLString else {
         return nil
      }
      return URL(string:urlString)
   }
}
