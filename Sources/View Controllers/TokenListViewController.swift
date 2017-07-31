//
//  TokenListViewController.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/29/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import UIKit

public extension NSNotification.Name {
   public static let TokenListViewControllerDidChangeTokens = NSNotification.Name(rawValue: "TokenListViewControllerDidChangeTokens")
}

class TokenListViewController: UITableViewController {

   public var tokens: [ExtendedToken] = [] {
      
      didSet {
         
         //animateRowChanges causes animation even if collections are the same
         //so we have to explicitly check that case
         guard !oldValue.diff(tokens).isEmpty else {
            return
         }
         
         tableView.animateRowChanges(
            oldData: oldValue,
            newData: tokens)
         
         NotificationCenter.default.post(name: .TokenListViewControllerDidChangeTokens, object: nil)
      }
   }

   override func viewDidLoad() {
      super.viewDidLoad()
      title = "Accounts"
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.setNavigationBarHidden(false, animated: animated)
   }

   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return tokens.count
   }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
      cell.textLabel?.text = tokens[indexPath.row].localName
      cell.detailTextLabel?.text = "Issuer: \(tokens[indexPath.row].token.token.issuer)"
      cell.accessoryType = .disclosureIndicator
      return cell
   }

   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      self.navigationController?.pushViewController(GeneratorViewController(token: tokens[indexPath.row]), animated: true)
   }

   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      if (editingStyle == .delete) {
         confirmDeleteKey(at: indexPath)
      }
   }

}

private extension TokenListViewController {
   func confirmDeleteKey(at indexPath: IndexPath) {
      let alert = UIAlertController(title: "Delete Key", message: "Are you sure you want to permanently delete \(tokens[indexPath.row].token.token.issuer)?", preferredStyle: .actionSheet)

      let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
         self.tokens.remove(at: indexPath.row)
      })

      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

      alert.addAction(deleteAction)
      alert.addAction(cancelAction)

      present(alert, animated: true, completion: nil)
   }
}
