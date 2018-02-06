//
//  AppDelegate.swift
//  OneTimePassword
//
//  Copyright (c) 2016 Matt Rubin and the OneTimePassword authors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import Base32
import Foundation
import OneTimePassword
import PermissionScope

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

   public var window: UIWindow? = UIWindow()
   var applicationViewController = ApplicationViewController()

   open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
      self.window?.rootViewController = applicationViewController
      self.window?.makeKeyAndVisible()
      self.window?.tintColor = UIColor(displayP3Red: 0.204, green: 0.596, blue: 0.859, alpha: 1.0)

      if let payload = launchOptions?[.remoteNotification] as? [String: AnyObject] {
         handleAnyPendingNotification(payload: payload)
      }
      return true
   }


   //example URL
   //epic2fa://addkey?issuer=Epic&name=Example&secret=ThisIsTheSecretKey

   //NFC READING
   //with iOS11 NFC tag reading capability, we could incorporate an NFC tag as Haiku's 2FA

   //PUSH NOTIFICATIONS
   //QR code must include web service to hit to register for push notifications + OTP
   //push notification must include web service to hit for verification + OTP: we send TOTP

   open func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
      guard let (optionalURL, optionalToken, addTokenNotification) = TokenCenter.main.addToken(with: url) else {
         return false
      }

      if let registrationURL = optionalURL,
         let authToken = optionalToken {
         let entry = OneTimeService.AuthStore.Entry(authorizationToken: authToken, webserviceURL: registrationURL)
         OneTimeService.temporaryAuthStore.add(entry)
      }

      addTokenNotification.post()
      return true
   }

   open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      guard let payload = userInfo["aps"] as? [String: AnyObject] else { return }
      handleAnyPendingNotification(payload: payload)
   }
}

extension AppDelegate {
   func handleAnyPendingNotification(payload: [String: AnyObject]) {
      //handle saving webserviceAuthToken??
   }
}

