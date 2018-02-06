//
//  Permissions.swift
//  OneTimePassword (iOS)
//
//  Created by Lucas Stomberg on 7/4/17.
//  Copyright © 2017 Matt Rubin. All rights reserved.
//

import UIKit
import PermissionScope
import UserNotifications



public extension NSNotification.Name {
   public static let PermissionsDidUpdateNotificationToken: NSNotification.Name = NSNotification.Name("PermissionsDidUpdateNotificationToken")
}

class Permissions: NSObject {
    public static let `default` = Permissions()
    var deviceNotificationToken: String?
    
    let notificationPermissions: PermissionScope = {
      let permission = PermissionScope()
      permission.addPermission(NotificationsPermission(notificationCategories: nil), message: "We use this to send you\r\nspam and love notes")
      return permission
    }()
    
    var hasAllPermissions: Bool {
      return (notificationPermissions.statusNotifications() == .authorized)
    }
    
    public func requestPermissions() {
        notificationPermissions.show({ (finished, result) in
            if(result.first(where: { $0.type == PermissionType.notifications })?.status == .authorized) {
                if(!UIApplication.shared.isRegisteredForRemoteNotifications) {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }, cancelled: nil)
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      let tokenParts = deviceToken.map { data -> String in
         return String(format: "%02.2hhx", data)
      }

      let token = tokenParts.joined()
      print("Device Token: \(token)")
      Permissions.default.deviceNotificationToken = token

      NotificationCenter.default.post(name: .PermissionsDidUpdateNotificationToken, object: nil)
    }


   func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Failed to register: \(error)")
   }
}


