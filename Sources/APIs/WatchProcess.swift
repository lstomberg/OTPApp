//
//  WatchProcess.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/30/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import Foundation
import WatchConnectivity
import OneTimePassword

class WatchProcess: NSObject {
   public static let `default` = WatchProcess()

   internal var tokens: [ExtendedToken]? {
      didSet {
         if let tokens = tokens {
            set(watchTokens: tokens)
         }
      }
   }

   /// Use `default` instead of calling yourself
   override init() {
      super.init()
      activateSession()
   }
   
   public enum ContextKey : String {
      case EncodedTokenURLToExtendedTokenMap
   }
}

///Private method extension dealing with sending tokens to watch
extension WatchProcess {
   /// Synchronizes tokens to AppleWatch storage
   /// This process is asynchronous
   func set(watchTokens tokens: [ExtendedToken]) {
      guard WCSession.default.activationState == .activated else {
         return
      }
      
      let encodedTokenMap = makeURLTokenMap(with: tokens)
      
      guard let data = try? JSONEncoder().encode(encodedTokenMap) else {
         return
      }
      
      try? WCSession.default.updateApplicationContext([ContextKey.EncodedTokenURLToExtendedTokenMap.rawValue : data])
   }
   
   //private helper
   func makeURLTokenMap(with tokens: [ExtendedToken]) -> [URL:ExtendedToken] {
      
      let map: [URL:ExtendedToken] = tokens.reduce( Dictionary<URL,ExtendedToken>()) { result, extendedToken in
         guard let tokenURL = try? extendedToken.token.token.toURL() else {
            return result
         }
         var result = result
         result[tokenURL] = extendedToken
         return result
      }
      
      return map
   }
}

/// iOS
/// WCSession is used to communicate with the AppleWatch app
/// A WCSessionDelegate is required to activate the default WCSession
extension WatchProcess: WCSessionDelegate {

   fileprivate func activateSession() {
      WCSession.default.delegate = self
      WCSession.default.activate()
   }

   func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
      //TODO: should we send the tokens over every time the WatchProcess activates?  We probably need to in case users
      // purchase a watch after having a token stored
      print("WCSession activationDidCompleteWith")

      if #available(iOS 10, *) {
         // iOS
      } else {
         // watchOS
         //LWS 1/31/2018 - commenting out to get to compile for iOS in Xcode 9.2
//         if (!session.receivedApplicationContext.isEmpty) {
//            deserializeToken(fromResponse: session.receivedApplicationContext)
//         } else {
//            session.sendMessage(["kind":"token"] as [String : Any], replyHandler: { (response) in
//               self.deserializeToken(fromResponse: response)
//            }, errorHandler: { (error) in
//               print("Error: \(error)")
//            })
//         }
      }
   }

#if os(iOS)
   func sessionDidBecomeInactive(_ session: WCSession) {
      print("WCSession sessionDidBecomeInactive")
   }

   func sessionDidDeactivate(_ session: WCSession) {
      print("WCSession sessionDidDeactivate")
   }
#endif

   func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
      //The watch sent a message to the phone app
      //TODO: is this really necessary?  In some testing, it appears sending a message to the watch on activationDidCompleteWith: doesn't always make it, so the watch might need to always request updates on launch
      print("WCSession didReceiveMessage")
      
      guard let key = message.first?.key,
         let tokens = tokens else {
            replyHandler([:])
            return
      }
      
      assert(message.count < 2, "UNDEVELOPED SAFE-GUARD: Only a single message key kind has been developed")
      assert(key == ContextKey.EncodedTokenURLToExtendedTokenMap.rawValue, "UNDEVELOPED SAFE-GUARD: Only EncodedTokenURLToExtendedTokenMap works")
      
      let encodedTokenMap = makeURLTokenMap(with: tokens)
      
      guard let data: Data = try? JSONEncoder().encode(encodedTokenMap) else {
         return
      }
      
      replyHandler([ContextKey.EncodedTokenURLToExtendedTokenMap.rawValue : data])
   }

   /// watchOS
   func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {

      //decode data
      guard let data = applicationContext[ContextKey.EncodedTokenURLToExtendedTokenMap.rawValue] as? Data,
         let encodedTokenMap = try? JSONDecoder().decode(Dictionary<URL,ExtendedToken>.self, from: data) else {
         return
      }

      //get all locally stored tokens
      let knownTokens = TokenCenter.main.allTokens()

      for (tokenURL, extendedToken) in encodedTokenMap {
         //extendedToken : Equatable based on uuid only
         if let _ = knownTokens.index(of: extendedToken) {
            TokenCenter.main.update(token: extendedToken)
         }
         TokenCenter.main.addToken(with: tokenURL, externallyProvided: extendedToken.endpoints)
      }
   }
}

