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
    var viewController = ApplicationRootViewController()
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        Permissions.default.incrementLaunchCount()
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Permissions.default.incrementLaunchCount()
    }
    
    //example URL
    //epic2fa://addkey?issuer=Epic&name=Example&secret=ThisIsTheSecretKey
    
    //NFC READING
    //with iOS11 NFC tag reading capability, we could incorporate an NFC tag as Haiku's 2FA
    
    //PUSH NOTIFICATIONS
    //QR code must include web service to hit to register for push notifications + OTP
    //push notification must include web service to hit for verification + OTP: we send TOTP
    
    open func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Received URL: \(url)")
        
        guard let host = url.host,
            host == "addkey",
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            let item = queryItems.first(where: { $0.name == "data" }),
            let base64String = item.value,
            let utf8Data = Data(base64Encoded: base64String),
            let environmentInfo = try? JSONDecoder().decode(EnvironmentInfo.self, from: utf8Data),
            let secret = environmentInfo.generator.secret,
            let generator = Generator(
                factor: .timer(period: environmentInfo.generator.interval),
                secret: Data(base64Encoded: secret)!,
                algorithm: EnvironmentInfo.Generator.Algorithm.algorithm(value: environmentInfo.generator.algorithm),
                digits: environmentInfo.generator.digits) else {
                    print("invalid data")
                    return false
        }
        
        let token = Token(name: environmentInfo.organization.accountName, issuer: environmentInfo.organization.name, generator: generator)
        let environment = Environment(info: environmentInfo, token: token)
        viewController.add(newToken: token)
        
        return true
    }
}

