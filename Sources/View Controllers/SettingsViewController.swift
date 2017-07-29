//
//  SettingsViewController.swift
//  OneTimePassword (iOS)
//
//  Created by Lucas Stomberg on 7/4/17.
//  Copyright © 2017 Matt Rubin. All rights reserved.
//

import UIKit
import PermissionScope

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        
        if(!Permissions.default.hasAllPermissions) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Permission", style: .plain, target: self, action: #selector(showNotificationPermissions))
        }
    }
    
    @objc func showNotificationPermissions() {
        Permissions.default.requestPermissions()
    }
}
