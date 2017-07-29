//
//  Token.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/29/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import Foundation


struct Token: Codable {
   let name: String
   let issuer: Organization
   let generator: Generator
   let endpoints: [Endpoint:WebService]
   let uuid: String

   struct Generator: Codable {
      let interval: TimeInterval
      let method: HashMethod
      let digits: Int
      let secret: String //base32 encoded secret

      enum HashMethod : String,Codable {
         case sha1
         case sha256
         case sha512
      }
   }

   enum Endpoint: Int,Codable {
      case registration
      case ack
   }
   struct WebService: Codable {
      let url: URL
   }

   struct Organization: Codable {
      let name: String
      let accountName: String
   }
}

extension Token: Equatable,Hashable {
   /// Compares two `Token`s for equality.
   public static func == (lhs: Token, rhs: Token) -> Bool {
      return (lhs.guid == rhs.guid)
   }

   public var hashValue: Int {
      return guid.hashValue
   }
}


