//
//  TOTPEnvironmentListViewController.swift
//  OneTimePasswordTestApp
//
//  Created by Lucas Stomberg on 7/3/17.
//  Copyright © 2017 Matt Rubin. All rights reserved.
//

import UIKit
import OneTimePassword

protocol EnvironmentListViewControllerDelegate: NSObjectProtocol {
    func didRemove(token: PersistentToken)
}

//what we get from registering a key
public struct EnvironmentInfo : Codable {
    //properties
    var localName: String
    let organization: Organization
    let generator: Generator
    let registration: WebService
    let acknowledge: WebService
    
    public struct Organization : Codable {
        let name: String
        let accountName: String
        let guid: String
    }
    
    public struct Generator : Codable {
        //properties
        let interval: TimeInterval
        let algorithm: Algorithm
        let digits: Int
        let secret: String? //base64 encoded
        
        public enum Algorithm : Int, Codable {
            case sha1
            case sha256
            case sha512
        }
    }
    
    public struct WebService : Codable {
        let oneTimeKey: String?
        let url: URL
    }
}

extension EnvironmentInfo: Hashable,Equatable {
    //hashable
    public var hashValue: Int {
        return organization.guid.hashValue
    }
    
    //equatable
    public static func ==(lhs: EnvironmentInfo, rhs: EnvironmentInfo) -> Bool {
        return lhs.organization.guid == rhs.organization.guid
    }
}

extension EnvironmentInfo.Generator.Algorithm {
    static func algorithm(value: EnvironmentInfo.Generator.Algorithm) -> OneTimePassword.Generator.Algorithm {
        switch value {
        case .sha1:
            return OneTimePassword.Generator.Algorithm.sha1
        case .sha256:
            return OneTimePassword.Generator.Algorithm.sha256
        case .sha512:
            return OneTimePassword.Generator.Algorithm.sha512
        }
    }
}

public struct Environment {
    public let info: EnvironmentInfo
    private var tokenIdentifierBase64: String
    
    init(info: EnvironmentInfo, tokenIdentifierBase64: String = "")  {
        self.info = info
        self.tokenIdentifierBase64 = tokenIdentifierBase64
        
//        guard let data = Data(base64Encoded:tokenIdentifierBase64) else {
//            throw Environment.Error.tokenDeserializationFailure
//        }
//
//        if ( (try? Keychain.sharedInstance.persistentToken(withIdentifier:data) ?? nil) == nil) {
//            throw Environment.Error.tokenWithIdentifierNotFoundInKeychain
//        }
    }
    
    public enum Error: Swift.Error {
        case tokenWithIdentifierNotFoundInKeychain
        case tokenDeserializationFailure
    }
}

public extension Environment {
    public var token: Token? {
        get {
            let data = Data(base64Encoded:tokenIdentifierBase64)!
            let persistentToken = (try? Keychain.sharedInstance.persistentToken(withIdentifier:data)) ?? nil
            return persistentToken?.token
        }
    }
    
    init(info: EnvironmentInfo, token: Token) {
        let persistentToken = (try? Keychain.sharedInstance.add(token)) ?? nil
        let base64 = persistentToken?.identifier.base64EncodedString()
        self.init(info: info, tokenIdentifierBase64: base64!)
    }
}

public extension Environment {
    public func sanitized() -> Environment {
        let generator = info.generator
        let sanitizedGenerator = EnvironmentInfo.Generator(interval: generator.interval, algorithm: generator.algorithm, digits: generator.digits, secret: nil)
        let sanitizedEnvironmentInfo = EnvironmentInfo(localName: info.localName, organization: info.organization,
                                                       generator: sanitizedGenerator, registration: info.registration, acknowledge: info.acknowledge)
        return Environment(info: sanitizedEnvironmentInfo, tokenIdentifierBase64: tokenIdentifierBase64)
    }
    
    public static func allEnvironments() -> [Environment] {
        guard let environments = UserDefaults.standard.data(forKey: "EpicEnvironnents") else {
            return []
        }
        return (try? JSONDecoder().decode([Environment].self,from: environments)) ?? []
    }
    
    public static func store(environments: [Environment]) {
        let sanitized = environments.flatMap { return $0.sanitized() }
        if let data = try? JSONEncoder().encode(sanitized) {
            UserDefaults.standard.set(data, forKey: "EpicEnvironments")
        }
    }
}


class TOTPEnvironmentListViewController: UITableViewController {
    
    public var environments: [Environment] = Environment.allEnvironments() {
        didSet {
            Environment.store(environments: environments)
            self.tableView.reloadData()
        }
    }

    public weak var delegate: EnvironmentListViewControllerDelegate?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    override init(style: UITableViewStyle) {
        super.init(style: .plain)
        title = "environments"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return environments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ID")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ID")
        }
        cell!.textLabel?.text = environments[indexPath.row].token?.name
        cell!.detailTextLabel?.text = "Issuer: \(environments[indexPath.row].token?.issuer)"
        cell!.accessoryType = .disclosureIndicator
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.navigationController?.pushViewController(TOTPProvidingViewController(aToken: environments[indexPath.row]), animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            confirmDeleteKey(at: indexPath)
        }
    }

    func confirmDeleteKey(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Key", message: "Are you sure you want to permanently delete \(environments[indexPath.row].token?.issuer)?", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.tableView.performBatchUpdates({
                self.tableView.deleteRows(at: [indexPath], with: .left)
                let environment = self.environments.remove(at: indexPath.row)
//                self.delegate?.didRemove(token: environment.token)

            }, completion: nil)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
