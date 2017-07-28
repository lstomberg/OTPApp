//
//  InterfaceController.swift
//  watchkitapp Extension
//
//  Created by Lucas Stomberg on 6/24/17.
//  Copyright © 2017 Matt Rubin. All rights reserved.
//

import WatchKit
import Foundation
import OneTimePassword
import Base32
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    @IBOutlet private var passwordLabel: WKInterfaceLabel!
    @IBOutlet private var passwordValidLabel: WKInterfaceLabel!
    @IBOutlet private var nextPasswordLabel: WKInterfaceLabel!

    public lazy var timer: Timer = {
        return Timer(timeInterval: TimeInterval(1), repeats: true, block: { [unowned self] _ in
            let seconds = Calendar.current.component(.second, from: Date())
            self.passwordLabel.setText(self.token?.currentPassword ?? "")
            self.passwordValidLabel.setText("\(29 - seconds % 30)s")
            let nextPassword = try? self.token?.generator.password(at: Date(timeIntervalSinceNow: 30)) ?? ""
            self.nextPasswordLabel.setText(nextPassword)
        })
    }()
    
    private var _token: PersistentToken?
    fileprivate var token: Token? {
        get {
            return _token?.token
        }
        
        set {
            print("Updating token")
            defer {
                updateView()
            }
            guard let token = newValue else {
                if (_token != nil) {
                    try? Keychain.sharedInstance.delete(_token!)
                    _token = nil
                }
                return
            }
            
            if (_token == nil) {
                _token = try? Keychain.sharedInstance.add(token)
            } else {
                _token = try? Keychain.sharedInstance.update(_token!, with: token)
            }
            updateView()
        }
    }
    
    var watchSession: WCSession? {
        didSet {
            if let session = watchSession {
                session.delegate = self
                session.activate()
            }
        }
    }
    
    override public init() {
        super.init()
        _token = (try? Keychain.sharedInstance.allPersistentTokens())?.first
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        updateView()
        watchSession = WCSession.default
    }
    
    private func updateView() {
        if (token != nil) {
            timer.fire()
            RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
        } else {
            self.passwordLabel.setText("No token")
            self.passwordValidLabel.setText("Setup in iPhone app")
            self.nextPasswordLabel.setText("")
        }
    }
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activation did complete")
        
        if (!session.receivedApplicationContext.isEmpty) {
            deserializeToken(fromResponse: session.receivedApplicationContext)
        } else {
            session.sendMessage(["kind":"token"] as [String : Any], replyHandler: { (response) in
                self.deserializeToken(fromResponse: response)
            }, errorHandler: { (error) in
                print("Error: \(error)")
            })
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("watch received app context: \(applicationContext)")
        deserializeToken(fromResponse: applicationContext)
    }
    
    private func deserializeToken(fromResponse response: [String:Any]) {
        guard let name = response["name"] as? String, let issuer = response["issuer"] as? String, let secretData = response["secret"] as? Data else {
            return
        }
        
        print("deserializing token")
        guard let generator = Generator(
            factor: .timer(period: 30),
            secret: secretData,
            algorithm: .sha1,
            digits: 6) else {
                print("Invalid generator parameters")
                return
        }
        
        let tokenProperty = Token(name: name, issuer: issuer, generator: generator)
        token = tokenProperty
    }
}
