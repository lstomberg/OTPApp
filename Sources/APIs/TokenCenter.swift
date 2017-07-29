//
//  TokenCenter.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/29/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import Foundation
//import OneTimePassword

//extension EnvironmentInfo.Generator.Algorithm {
//   static func algorithm(value: EnvironmentInfo.Generator.Algorithm) -> OneTimePassword.Generator.Algorithm {
//      switch value {
//      case .sha1:
//         return OneTimePassword.Generator.Algorithm.sha1
//      case .sha256:
//         return OneTimePassword.Generator.Algorithm.sha256
//      case .sha512:
//         return OneTimePassword.Generator.Algorithm.sha512
//      }
//   }
//}

//TokenDescriptor
//public extension Environment {
//   public var token: Token? {
//      get {
//         let data = Data(base64Encoded:tokenIdentifierBase64)!
//         let persistentToken = (try? Keychain.sharedInstance.persistentToken(withIdentifier:data)) ?? nil
//         return persistentToken?.token
//      }
//   }
//
//   init(info: EnvironmentInfo, token: Token) {
//      let persistentToken = (try? Keychain.sharedInstance.add(token)) ?? nil
//      let base64 = persistentToken?.identifier.base64EncodedString()
//      self.init(info: info, tokenIdentifierBase64: base64!)
//   }
//}

//public extension Environment {
//   public func sanitized() -> Environment {
//      let generator = info.generator
//      let sanitizedGenerator = EnvironmentInfo.Generator(interval: generator.interval, algorithm: generator.algorithm, digits: generator.digits, secret: nil)
//      let sanitizedEnvironmentInfo = EnvironmentInfo(localName: info.localName, organization: info.organization,
//                                                     generator: sanitizedGenerator, registration: info.registration, acknowledge: info.acknowledge)
//      return Environment(info: sanitizedEnvironmentInfo, tokenIdentifierBase64: tokenIdentifierBase64)
//   }
//
//   public static func allEnvironments() -> [Environment] {
//      guard let environments = UserDefaults.standard.data(forKey: "EpicEnvironnents") else {
//         return []
//      }
//      return (try? JSONDecoder().decode([Environment].self,from: environments)) ?? []
//   }
//
//   public static func store(environments: [Environment]) {
//      let sanitized = environments.flatMap { return $0.sanitized() }
//      if let data = try? JSONEncoder().encode(sanitized) {
//         UserDefaults.standard.set(data, forKey: "EpicEnvironments")
//      }
//   }
//}









class TokenCenter {
   public static let main = TokenCenter()

   public func allTokens() -> [Token] {
      return Array<Token>()
   }

   public func token(for uuid: String) -> Token? {
      return allTokens().first(where: {$0.uuid == uuid})
   }

   public func add(token: Token) {

   }
}






