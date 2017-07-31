//
//  ApplicationViewController.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/29/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import UIKit
import Diff.Swift

class ApplicationViewController: UINavigationController {
   
   let emptyState = EmptyStateViewController()
   
   let tokenList: TokenListViewController = TokenListViewController()

   override func viewDidLoad() {
      super.viewDidLoad()
      self.view.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
      
      configureViewControllers()

      NotificationCenter.default.addObserver(self, selector: #selector(configureViewControllers), name: .TokenCenterDidUpdateTokens, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(updateTokenCenter), name: .TokenListViewControllerDidChangeTokens, object: nil)
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
}
