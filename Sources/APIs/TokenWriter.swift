//
//  WatchExtendedTokenWriter.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/29/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import Foundation
import WatchConnectivity
import OneTimePassword

/// ExtendedTokenWriterType protocol
protocol ExtendedTokenWriterType {

   /// These methods return success or failure of execution
   func add(_ extendedToken: ExtendedToken) -> Bool
   func update(_ extendedToken: ExtendedToken) -> Bool
   func delete(_ extendedToken: ExtendedToken) -> Bool
}

protocol LocalExtendedTokenWriterType : ExtendedTokenWriterType {

   /// returns if an extended token exists
   func exists(_ extendedToken: ExtendedToken) -> Bool
}

/// TokenWriter struct
/// This class is an abstraction layer around the specific local and watch implementations for
/// adding, updating, and deleting tokens
/// It is also the central location to define the global local and watch writers
struct ExtendedTokenWriter {
   public static let local: LocalExtendedTokenWriterType = UserDefaults.standard
   public static let watch: ExtendedTokenWriterType = WatchProcess.default

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
extension UserDefaults: LocalExtendedTokenWriterType {
   func exists(_ extendedToken: ExtendedToken) -> Bool {
      return (self.object(forKey: ExtendedTokenWriter.key(for: extendedToken)) != nil)
   }

   func add(_ extendedToken: ExtendedToken) -> Bool {
      return update(extendedToken)
   }

   func update(_ extendedToken: ExtendedToken) -> Bool {
      guard let data = try? JSONEncoder().encode(extendedToken) else {
         return false
      }

      self.set(data, forKey: ExtendedTokenWriter.key(for: extendedToken))
      return true
   }

   func delete(_ extendedToken: ExtendedToken) -> Bool {
      self.removeObject(forKey: ExtendedTokenWriter.key(for: extendedToken))
      return true
   }
}

/// The WatchProcess is used to store ExtendedTokens to the watch
/// We aren't trying to be performant in our rarely-used small-sized updates to the watch
/// Any time an add, update, or delete occurs, sync the entire token data set
extension WatchProcess: ExtendedTokenWriterType {

   //TODO: implement
   func add(_ extendedToken: ExtendedToken) -> Bool {
      tokens = TokenCenter.main.allTokens()
      return true
   }

   //TODO: implement
   func update(_ extendedToken: ExtendedToken) -> Bool {
      tokens = TokenCenter.main.allTokens()
      return true
   }

   //TODO: implement
   func delete(_ extendedToken: ExtendedToken) -> Bool {
      tokens = TokenCenter.main.allTokens()
      return true
   }
}

