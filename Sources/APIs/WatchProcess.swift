//
//  WatchProcess.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/30/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchProcess: NSObject {
   public static let `default` = WatchProcess()

   private var tokens: Set<ExtendedToken>? {
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

   /// Synchronizes tokens to AppleWatch storage
   /// This process is asynchronous
   private func set(watchTokens tokens: Set<ExtendedToken>) {
      guard WCSession.default.activationState == .activated else {
         return
      }

      let encodedTokenMap: [URL:ExtendedToken] = tokens.reduce( Dictionary<URL,ExtendedToken>()) { result, extendedToken in
         guard let tokenURL = try? extendedToken.token.token.toURL() else {
            return result
         }
         var result = result
         result[tokenURL] = extendedToken
         return result
      }

      guard let data = try? JSONEncoder().encode(encodedTokenMap) else {
         return
      }

      try? WCSession.default.updateApplicationContext(["EncodedTokenURLToExtendedTokenMap" : data])
   }
}

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
      //      updateWatch()
   }

   func sessionDidBecomeInactive(_ session: WCSession) {
      print("WCSession sessionDidBecomeInactive")
   }

   func sessionDidDeactivate(_ session: WCSession) {
      print("WCSession sessionDidDeactivate")
   }

   func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
      //The watch sent a message to the phone app
      //TODO: is this really necessary?  In some testing, it appears sending a message to the watch on activationDidCompleteWith: doesn't always make it, so the watch might need to always request updates on launch
      print("WCSession didReceiveMessage")
      //      replyHandler(applicationContext())
   }
}
