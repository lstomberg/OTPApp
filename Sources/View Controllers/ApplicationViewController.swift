//
//  ApplicationViewController.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/29/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import UIKit
import Differ
import UserNotifications

class ApplicationViewController: UINavigationController {
   
   let emptyState = EmptyStateViewController()
   
   let tokenList: TokenListViewController = TokenListViewController()

   override func viewDidLoad() {
      super.viewDidLoad()
      self.view.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
      
      configureViewControllers()
      registerForPushNotifications()

      NotificationCenter.default.addObserver(self, selector: #selector(configureViewControllers), name: .TokenCenterDidUpdateTokens, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(registerForPushNotifications), name: .TokenCenterDidUpdateTokens, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(updateTokenCenter), name: .TokenListViewControllerDidChangeTokens, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(callPushNotificationRegistrationService), name: .PermissionsDidUpdateNotificationToken, object: nil)
   }
}

/// Private methods extension
extension ApplicationViewController {

   @objc
   func configureViewControllers() {
      let tokens = TokenCenter.main.allTokens()
      
      guard !tokens.isEmpty else {
         viewControllers = [emptyState]
         return
      }
      
      let listOnScreen = viewControllers.contains(tokenList)
      if(!listOnScreen) {
         viewControllers = [tokenList]
      }
      
      tokenList.tokens = tokens
   }

   @objc
   func registerForPushNotifications() {
      let tokens = TokenCenter.main.allTokens()

      guard !tokens.isEmpty else {
         return
      }

      guard Permissions.default.hasAllPermissions else {
         Permissions.default.requestPermissions()
         return
      }

      UIApplication.shared.registerForRemoteNotifications()
   }
   
   @objc
   func updateTokenCenter() {
      let from = TokenCenter.main.allTokens()
      let to = tokenList.tokens
      let diff = from.diff(to)
      
      assert(diff.count < 2, "UNDEVELOPED SAFE-GUARD: Implementation for multiple changes or multiple change types not implemented")
      
      //this case is possible when updating tokenList due to changes in TokenCenter
      //in that case, diff.count == 0
      guard let first = diff.first else {
            return
      }
      
      switch first {
      case let .delete(at: index):
         TokenCenter.main.remove(token: from[index])
      case .insert(at: _):
         fatalError("UNDEVELOPED SAFE-GUARD: Inserting from the view has not been implemented")
      }
   }

   @objc
   func callPushNotificationRegistrationService() {
      guard let onlyToken = TokenCenter.main.allTokens().first,
         let pushToken = Permissions.default.deviceNotificationToken,
         let serverURL = onlyToken.endpoints[.registration]?.url else {
            return
      }

      let serverGUID = String(onlyToken.hashValue)
      guard let service = OneTimeService.registration(serverURL: serverURL, serverGUID: serverGUID, pushNotificationToken: pushToken) else {
         let dict: [String:Any] = ["serverURL": serverURL, "serverGUID": serverGUID, "pushToken": pushToken]
         print ("Unable to call service with parameters:\n\(dict as AnyObject)\nIf parameters look good, you probably didn't have a valid onetime-service-token")

         let alertController = UIAlertController(title: "Error, unable to call registration service.", message: "Parameters:\n\(dict as AnyObject)\nIf parameters look good, you probably didn't have a valid onetime-service-token", preferredStyle: .alert)
         alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
         return
      }
      service.execute()
   }
}

//debugging
extension ApplicationViewController {
   // Enable detection of shake motion
   override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
      if motion == .motionShake {
         print("Why are you shaking me?")
         for extendedToken in TokenCenter.main.allTokens() {
            TokenCenter.main.remove(token: extendedToken)
         }
      }
   }
}
