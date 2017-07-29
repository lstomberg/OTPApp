//
//  ApplicationRootViewController.swift
//  OneTimePasswordTestApp
//
//  Created by Lucas Stomberg on 7/3/17.
//  Copyright © 2017 Matt Rubin. All rights reserved.
//

import UIKit
import OneTimePassword
import Base32
import WatchConnectivity
import NetworkExtension

class ApplicationRootViewController: UINavigationController {
    
    internal lazy var watchSession: WCSession = {
        let session = WCSession.default
        session.delegate = self
        session.activate()
        return session
    }()
    
    internal lazy var listViewController: TOTPEnvironmentListViewController = {
        let controller = TOTPEnvironmentListViewController()
        controller.delegate = self
        return controller
    }()
    let helpViewController = HelpViewController()
    let settingsViewController = SettingsViewController()
    var tokens: [PersistentToken] = Array((try? Keychain.sharedInstance.allPersistentTokens()) ?? Set()) {
        didSet {
            updateListView()
            updateWatch()
        }
    }
    
    public func add(newToken token: Token) {
        guard let pToken = try? Keychain.sharedInstance.add(token) else {
            return;
        }
        tokens.append(pToken)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        viewControllers = [listViewController]
        isToolbarHidden = false
        
        let settings = UIBarButtonItem(title: "\u{2699}\u{0000FE0E}", style: .plain, target: self, action: #selector(settingsButtonTapped))
        settings.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 24.0)!], for: .normal)
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        listViewController.toolbarItems = [flex,settings]
        
        NotificationCenter.default.addObserver(forName: .UIApplicationWillResignActive, object: nil, queue: nil) { _ in
            if(!self.tokens.isEmpty) {
                self.helpViewController.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("initWithCoder: unsupported")
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    @objc func addButtonTapped() {
        helpViewController.showsClose = true
        present(helpViewController, animated: true, completion: nil)
    }
    
    @objc func settingsButtonTapped() {
        present(UINavigationController(rootViewController: settingsViewController), animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateListView()
    }
    
    func updateListView() {
//        listViewController.tokens = tokens

        helpViewController.modalPresentationStyle = .fullScreen
        switch tokens.count {
        case 0:
            helpViewController.showsClose = false
            present(helpViewController, animated: false, completion: nil)
        default:
            helpViewController.dismiss(animated: false, completion: nil)
            
            let infoButton = UIButton(type: .infoLight)
            infoButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
            listViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        }
    }
    
    fileprivate func updateWatch() {
        guard watchSession.activationState == .activated else {
            return
        }
        
        try? watchSession.updateApplicationContext(applicationContext())
    }
    
    fileprivate func applicationContext() -> [String:Any] {
        return ["tokens":tokens.map {$0.dictionaryRepresentation()}]
    }
}

extension PersistentToken {
    func dictionaryRepresentation() -> [String:Any] {
        let name = self.token.name
        let issuer = self.token.issuer
        let secretData = self.token.generator.secret
        return ["name":name, "issuer":issuer, "secret":secretData] as [String : Any]
    }
}


extension ApplicationRootViewController: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activation did complete")
        updateWatch()
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        print("session did become inactive")
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        print("session did deactivate")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("session did receive message")
        replyHandler(applicationContext())
    }
}

extension ApplicationRootViewController: EnvironmentListViewControllerDelegate {
    
    func didRemove(token: PersistentToken) {
        if let index = tokens.index(of: token) {
            tokens.remove(at: index)
            try? Keychain.sharedInstance.delete(token)
        }
    }
}

class HelpViewController : UIViewController {

    public var showsClose = false {
        didSet {
            self.helpView.centerButton.isHidden = !showsClose
        }
    }

    private lazy var helpView: HelpView = HelpView()

    override func loadView() {
        self.view = helpView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.helpView.centerLabel.text = "Scan QR code or open epic2fa:// link"
        self.helpView.centerButton.setTitle("Close", for: .normal)
        self.helpView.centerButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }

    @objc
    func close() {
        dismiss(animated: true, completion: nil)
    }
}

class HelpView : UIView {
    lazy var centerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .light)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)

        label.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        return label
    }()

    lazy var centerButton: UIButton = {
        let button = UIButton(type: .roundedRect)

        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)

        button.topAnchor.constraint(equalTo: self.centerLabel.bottomAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: self.centerLabel.centerXAnchor).isActive = true

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.97, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("initWithCoder: not a valid initializer")
    }
}




