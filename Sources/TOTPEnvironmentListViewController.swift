////
////  TOTPEnvironmentListViewController.swift
////  OneTimePasswordTestApp
////
////  Created by Lucas Stomberg on 7/3/17.
////  Copyright © 2017 Matt Rubin. All rights reserved.
////
//
//import UIKit
//import OneTimePassword
//
//protocol EnvironmentListViewControllerDelegate: NSObjectProtocol {
//    func didRemove(token: PersistentToken)
//}
//
//
//
//class TOTPEnvironmentListViewController: UITableViewController {
//    
////    public var environments: [Environment] = Environment.allEnvironments() {
////        didSet {
////            Environment.store(environments: environments)
////            self.tableView.reloadData()
////        }
////    }
//
//    public weak var delegate: EnvironmentListViewControllerDelegate?
//
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("This class does not support NSCoding")
//    }
//
//    override init(style: UITableViewStyle) {
//        super.init(style: .plain)
//        title = "environments"
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return environments.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: "ID")
//        if cell == nil {
//            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ID")
//        }
//        cell!.textLabel?.text = environments[indexPath.row].token?.name
//        cell!.detailTextLabel?.text = "Issuer: \(environments[indexPath.row].token?.issuer)"
//        cell!.accessoryType = .disclosureIndicator
//        return cell!
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        self.navigationController?.pushViewController(TOTPProvidingViewController(aToken: environments[indexPath.row]), animated: true)
//    }
//
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if (editingStyle == .delete) {
//            confirmDeleteKey(at: indexPath)
//        }
//    }
//
//    func confirmDeleteKey(at indexPath: IndexPath) {
//        let alert = UIAlertController(title: "Delete Key", message: "Are you sure you want to permanently delete \(environments[indexPath.row].token?.issuer)?", preferredStyle: .actionSheet)
//
//        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
//            self.tableView.performBatchUpdates({
//                self.tableView.deleteRows(at: [indexPath], with: .left)
//                let environment = self.environments.remove(at: indexPath.row)
////                self.delegate?.didRemove(token: environment.token)
//
//            }, completion: nil)
//        })
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        alert.addAction(deleteAction)
//        alert.addAction(cancelAction)
//        
//        present(alert, animated: true, completion: nil)
//    }
//}

