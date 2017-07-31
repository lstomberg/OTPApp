//
//  ApplicationViewController.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/29/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import UIKit

class ApplicationViewController: UINavigationController {

   override func viewDidLoad() {
      super.viewDidLoad()
      self.view.backgroundColor = UIColor(white: 0.97, alpha: 1.0)

      if TokenCenter.main.allTokens().isEmpty {
         viewControllers = [InstructionsViewController()]
      } else {
         viewControllers = [TokenListViewController()]
      }
   }

   
}
