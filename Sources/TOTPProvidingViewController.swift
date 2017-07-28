//
//  TOTPProvidingViewController.swift
//  OneTimePassword
//
//  Created by Lucas Stomberg on 6/24/17.
//  Copyright © 2017 Matt Rubin. All rights reserved.
//

import UIKit
import OneTimePassword

class TOTPProvidingViewController: UIViewController {
    
    let token: PersistentToken
    var timer: Timer?
    
    lazy var tokenView: TOTPProvidingView = TOTPProvidingView()
    
    init(aToken: PersistentToken) {
        token = aToken
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func loadView() {
        view = tokenView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateView), userInfo: nil, repeats: true)
        updateView()
    }
    
    @objc func updateView() {
        let seconds = Calendar.current.component(.second, from: Date())
        guard let currentPassword = self.token.token.currentPassword,
            !currentPassword.isEmpty else {
                self.tokenView.password = "Unable to generate token"
                self.tokenView.passwordValidFor = nil
                self.tokenView.nextPassword = ""
                return
        }
        self.tokenView.password = currentPassword
        self.tokenView.passwordValidFor = 29 - seconds%30
        self.tokenView.nextPassword = (try? self.token.token.generator.password(at: Date(timeIntervalSinceNow: 30))) ?? ""
    }
    

}


class TOTPProvidingView : UIView {
    
    private var otpLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var nextOtpLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public var password: String = "" {
        didSet {
            otpLabel.text = password
        }
    }
    public var passwordValidFor: Int? {
        didSet {
            guard let passwordValidFor = passwordValidFor else {
                timeLabel.text = nil
                return
            }
            timeLabel.text = "Valid For: \(passwordValidFor)"
        }
    }
    public var nextPassword: String = "" {
        didSet {
            if (nextPassword.isEmpty) {
                nextOtpLabel.text = nil
            } else {
                nextOtpLabel.text = "Next: \(nextPassword)"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(otpLabel)
        addSubview(timeLabel)
        addSubview(nextOtpLabel)
        
        otpLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        otpLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: otpLabel.bottomAnchor).isActive = true
        
        nextOtpLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        nextOtpLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20).isActive = true
        
        backgroundColor = UIColor.white
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
}


