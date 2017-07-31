//
//  WatchTokenWriter.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/29/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import Foundation
import WatchConnectivity
import OneTimePassword

/// TokenWriterType protocol
protocol TokenWriterType {
   func add(_ extendedToken: ExtendedToken)
   func update(_ extendedToken: ExtendedToken)
   func delete(_ extendedToken: ExtendedToken)
}

/// TokenWriter struct
/// This class is an abstraction layer around the specific local and watch implementations for
/// adding, updating, and deleting tokens
/// It is also the central location to define the global local and watch writers
struct TokenWriter {
   public static let local: TokenWriterType = UserDefaults.standard
   public static let watch: TokenWriterType = WatchProcess.default

   /// Objects serialized to storage require having unique identifiers
   /// While different implementations may make use of multiple factors for grouping
   /// this method returns an easy to use string concatinated key to both
   /// uniquely identify and group all stored tokens.
   internal static func key(for extendedToken: ExtendedToken) -> String {
      return "ExtendedToken_" + extendedToken.uuid
   }

   /// During deserialization, if there is no other method for identifying
   /// the type of object being referenced, callers can use this method to
   /// identify keys that represent an ExtendedToken
   internal static func isExtendedTokenKey(_ key: String) -> Bool {
      return key.hasPrefix("ExtendedToken_")
   }
}

/// UserDefaults are used to store ExtendedTokens locally
extension UserDefaults: TokenWriterType {
   func add(_ extendedToken: ExtendedToken) {
      update(extendedToken)
   }

   func update(_ extendedToken: ExtendedToken) {
      if let data = try? JSONEncoder().encode(extendedToken) {
         self.set(data, forKey: TokenWriter.key(for: extendedToken))
      }
   }

   func delete(_ extendedToken: ExtendedToken) {
      self.removeObject(forKey: TokenWriter.key(for: extendedToken))
   }
}

/// The WatchProcess is used to store ExtendedTokens to the watch
/// We aren't trying to be performant in our rarely-used small-sized updates to the watch
/// Any time an add, update, or delete occurs, sync the entire token data set
extension WatchProcess: TokenWriterType {

   func add(_ extendedToken: ExtendedToken) {
      tokens = TokenCenter.main.allTokens()
   }

   func update(_ extendedToken: ExtendedToken) {
      tokens = TokenCenter.main.allTokens()
   }

   func delete(_ extendedToken: ExtendedToken) {
      tokens = TokenCenter.main.allTokens()
   }
}

