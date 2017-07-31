//
//  TokenListViewController.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/29/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import UIKit

class TokenListViewController: UITableViewController {
   
   public var tokens: [ExtendedToken] = [] {
      didSet {
         tableView.reloadData()
      }
   }

   override func viewDidLoad() {
      super.viewDidLoad()
      title = "Accounts"
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
   }

   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return tokens.count
   }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
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
         self.tableView.performBatchUpdates({
            self.tableView.deleteRows(at: [indexPath], with: .left)
            //TODO: figure out how to delete from this view only class
         }, completion: nil)
      })

      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

      alert.addAction(deleteAction)
      alert.addAction(cancelAction)

      present(alert, animated: true, completion: nil)
   }
}
