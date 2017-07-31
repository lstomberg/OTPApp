//
//  TokenCenter.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/29/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import Foundation
import OneTimePassword

/// This extension adds the link between our ExtendedToken data and OTP.PersistentToken
extension ExtendedToken {

   /// Return the PersistentToken that has the same identifier as our uuid
   var token: PersistentToken {
      return TokenCenter.main.persistentToken(withUUID: uuid)!
   }

   /// This method does a non-forced unwrap checking for a persistentToken associated with our uuid
   /// The token property is force unwrapped because we are ensuring it exists during load and
   /// it is easier to work with a non-optional property
   fileprivate var hasValidToken: Bool {
      return (TokenCenter.main.persistentToken(withUUID: uuid) != nil)
   }
}

/// The TokenCenter is our central place to add Tokens and remove and update ExtendedTokens
struct TokenCenter {

   /// Use the main center instead of creating your own
   public static let main = TokenCenter()

   /// The supported URL format follows the RFC standards for a totp / hotp token URI
   ///
   ///       URI scheme: otpauth://TYPE/LABEL?PARAMETERS
   ///
   ///       TYPE: (totp) or (hotp)
   ///       LABEL: (accountname) or (issuer\:*\saccountname) where \: is one of [:,%3A] and \s is %20
   ///       PARAMETERS:
   ///         secret     Required          Base32 encoded
   ///         issuer     Recommended       URL encoded, equal to LABEL if both are present
   ///         algorithm  Optional,#sha1    SHA1, SHA256, SHA512
   ///         digits     Optional,#6       6-8 digit output
   ///         counter    hotp-Required     Initial HOTP counter
   ///         period     totp-Optional,#30 TOTP time step in seconds
   ///
   /// Additionally, the additional parameters are also supported
   ///         ack          Optional    URL endpoint to acknowledge a push notification received
   ///         registration Optional    URL endpoint to register with Epic server our push notification ID
   public func addToken(with url: URL) {
      guard let token = Token(url: url),
         let persistentToken = try? Keychain.sharedInstance.add(token) else {
         return
      }
      let endpoints = parseEndpoints(in: url)
      let localName = persistentToken.token.name

      let extendedToken = ExtendedToken(localName: localName, endpoints: endpoints, uuid: persistentToken.identifier.base64EncodedString())
      TokenWriter.local.add(extendedToken)
   }

   /// Updates the localName and endpoints for an ExtendedToken based on its uuid
   public func update(token: ExtendedToken) {
      TokenWriter.local.update(token)
   }

   /// Removes the ExtendedToken and associated PersistentToken from this device
   /// This action is non-reversable
   public func remove(token: ExtendedToken) {
      try? Keychain.sharedInstance.delete(token.token)
      TokenWriter.local.delete(token)
   }

   /// Lists all valid ExtendedTokens stored on this device
   /// This method validates all loaded Tokens to ensure there is a corresponding PersistentToken
   /// stored in the Keychain.  If there is not, it is not returned in the set
   public func allTokens() -> Set<ExtendedToken> {
      let dict = UserDefaults.standard.dictionaryRepresentation()
      let tokenValues = dict.flatMap { TokenWriter.isExtendedTokenKey($0.key) ? $0.value as? Data : nil }
      let tokens: [ExtendedToken] = tokenValues.flatMap { try? JSONDecoder().decode(ExtendedToken.self, from: $0) }

      //if we dont have an associated PersistentToken for some reason, dont show this token and log
      //a message to the error log
      let validTokens: [ExtendedToken] = tokens.flatMap { token in
         if token.hasValidToken {
            return token
         }
         //TODO: log message to error log
         return nil
      }

      return Set(validTokens)
   }
}

/// Private 'helper' methods for the TokenCenter
private extension TokenCenter {

   /// Returns a PersistentToken identified by a uuid
   /// This method wraps OneTimePassword's Keychain instance and the conversion from Data <-> Base64String
   func persistentToken(withUUID uuid: String) -> PersistentToken? {
      guard let data = Data(base64Encoded: uuid) else {
            return nil
      }

      let persistentToken = (try? Keychain.sharedInstance.persistentToken(withIdentifier: data)) ?? nil
      return persistentToken
   }
}

/// Private helper method to extract parts of the URL associated with Web Service calls
/// This method didn't make sense to be part of the TokenCenter so it was made outside a struct/class as private
private func parseEndpoints(in url: URL) -> [ExtendedToken.Endpoint : ExtendedToken.WebService] {
   var endpoints: [ExtendedToken.Endpoint : ExtendedToken.WebService] = [:]

   if let registration = url.queryValue(for: "registration"),
      let URL = URL(string: registration) {
      endpoints[.registration] = ExtendedToken.WebService(url: URL)
   }

   if let ack = url.queryValue(for: "ack"),
      let URL = URL(string: ack) {
      endpoints[.ack] = ExtendedToken.WebService(url: URL)
   }

   return endpoints
}

/// Private URL extension to easily return the value of a queryItem key
/// For reference, the URL structure is SCHEME://HOST/PATH?queryItemKEY=VALUE&queryItemKEY2=VALUE
private extension URL {
   func queryValue(for key:String) -> String? {
      let components = URLComponents(url: self, resolvingAgainstBaseURL: false)
      let queryItems = components?.queryItems
      let item = queryItems?.first(where: { $0.name == key })
      return item?.value
   }
}












//protocol URLConvertible {
//   init?(url: URL)
//}
//
//extension OneTimePassword.Token : URLConvertible {
//   init?(url: URL) {
//      self.init(url: url)
//   }
//}
//
//extension ExtendedToken : URLConvertible {
//   init?(url: URL) {
//
//   }
//}
//
//   private func makeToken(from url: URL) -> (OneTimePassword.Token,Token)? {
//      /*
//       URI scheme: otpauth://TYPE/LABEL?PARAMETERS
//
//       TYPE: (totp) or (hotp)
//       LABEL: (accountname) or (issuer\:*\saccountname) where \: is one of [:,%3A] and \s is %20
//       PARAMETERS:
//       secret     Required          Base32 encoded
//       issuer     Recommended       URL encoded, equal to LABEL if both are present
//       algorithm  Optional,#sha1    SHA1, SHA256, SHA512
//       digits     Optional,#6       6-8 digit output
//       counter    hotp-Required     Initial HOTP counter
//       period     totp-Optional,#30 TOTP time step in seconds
//       */
//   }
//}






























//      let type = url.host
//      let labelValue: String? = url.pathComponents.first
//      let secretValue: String? = url.queryValue(for: "secret")
//      let issuerValue: String? = url.queryValue(for: "issuer")
//      let algorithmValue: String = url.queryValue(for: "algorithm") ?? "sha1"
//      let digitsValue: String = url.queryValue(for: "digits") ?? "6"
//      let periodValue: String = url.queryValue(for: "period") ?? "30"

//      guard type == "totp",
//         let label = labelValue,
//         let (accountName, issuerFromLabel) = parse(LABEL: label),
//         let secret = secretValue,
//         let interval = Double(periodValue),
////         let method = Token.Generator.HashMethod(rawValue: algorithmValue),
//         let digits = Int(digitsValue),
//         let issuer = issuerFromLabel ?? issuerValue,
//         (issuerFromLabel == nil || issuerFromLabel == issuer),
//         (issuerValue == nil || issuerValue == issuer) else {
//            return nil
//      }

//      var endpoints: [Token.Endpoint:Token.WebService] = [:]
//      if let registration = url.queryValue(for: "registration"),
//         let URL = URL(string: registration) {
//         endpoints[.registration] = Token.WebService(url: URL)
//      }
//      if let ack = url.queryValue(for: "ack"),
//         let URL = URL(string: ack) {
//         endpoints[.ack] = Token.WebService(url: URL)
//      }
//
//      let algorithm: Generator.Algorithm
//      switch(algorithmValue) {
//      case "sha1": algorithm = .sha1
//      case "sha256": algorithm = .sha256
//      case "sha512": algorithm = .sha512
//      default: return nil
//      }

//OneTimePassword.Token(url: url)

//      let generator = OneTimePassword.Generator(factor: .timer(period: interval), secret: Data(base32String: secret.base32()) , algorithm: algorithm, digits: digits)




//      let generator = Token.Generator(interval: interval, method: method, digits: digits, secret: secret)
//      let origin = Token.Organization(name: issuer, accountName: accountName)
//      let token = Token(name: "Unnamed", issuer: origin, generator: generator, endpoints: endpoints, uuid: UUID().uuidString)
//return token
//}
//   private func parse(LABEL label: String) -> (String,String?)? {
//      guard let label = label.removingPercentEncoding else {
//         return nil
//      }
//
//      let pieces = label.components(separatedBy: ":")
//      guard !pieces.isEmpty, pieces.count < 3 else {
//         return nil
//      }
//
//      let accountName = pieces.last!.trimmingCharacters(in: .whitespaces);
//      let issuer = (pieces.count == 2) ? pieces[0] : nil
//      return (accountName, issuer)
//   }
//}
//







