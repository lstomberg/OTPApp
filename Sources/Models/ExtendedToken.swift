//
//  Token.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/29/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import Foundation

/// ExtendedToken holds Epic specific information associated with a token
struct ExtendedToken: Codable {

   /// The display name for this structure
   /// ExtendedTokens should be created with a reasonable localName string when
   /// deserializing from a URL
   let localName: String

   /// Dictionary of web services to point to when registering for push notifications and
   /// acknowledging receiving a push notification
   /// A dictionary is used instead of associating a URL in the Endpoint enum to guarentee key uniqueness
   let endpoints: [Endpoint:WebService]


   /// base64 encoded Data string that identifies the internal OneTimePassword PersistentToken.
   let uuid: String

   /// Defines the set of different web services that this class knows about
   enum Endpoint: Int,Codable {
      case registration
      case ack
   }

   /// Encapsulates the web service information contained in Epic's TOTP URL
   struct WebService: Codable {
      let url: URL
   }
}

/// Hashable and Equatable conformance
extension ExtendedToken: Hashable {

   /// :Equatable
   public static func == (lhs: ExtendedToken, rhs: ExtendedToken) -> Bool {
      return lhs.uuid == rhs.uuid
   }

   /// :Hashable
   public var hashValue: Int {
      return uuid.hash
   }
}
