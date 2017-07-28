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

class Permissions: NSObject {
    public static let `default` = Permissions()
    
    public var webserviceAuthToken: String?
    
    fileprivate var deviceNotificationToken: Data?
    
    let notificationPermissions: PermissionScope = {
        let permission = PermissionScope()
        permission.addPermission(NotificationsPermission(notificationCategories: nil), message: "We use this to send you\r\nspam and love notes")
        return permission
    }()
    
    var hasAllPermissions: Bool {
        get {
            return (notificationPermissions.statusNotifications() == .authorized)
        }
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
    
    var applicationLaunchCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: "ApplicationLaunchCount")
        }
        set {
            UserDefaults.standard.set(applicationLaunchCount+1, forKey: "ApplicationLaunchCount")
            UserDefaults.standard.synchronize()
        }
    }
    
    public func incrementLaunchCount() {
        applicationLaunchCount += 1
        switch notificationPermissions.statusNotifications() {
        case .unknown:
            requestPermissions()
            break
            
        case .disabled:
            fallthrough
        case .unauthorized:
            if (applicationLaunchCount % 8 == 0) {
                requestPermissions()
            }
            break
            
        case .authorized:
            break
        }
        
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Permissions.default.deviceNotificationToken = deviceToken
    }
}

extension OneTimeService {
    func deviceNotificationToken() -> Data? {
        return Permissions.default.deviceNotificationToken
    }
}


