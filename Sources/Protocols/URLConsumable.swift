//
//  URLConsumable.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/29/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import Foundation

protocol URLConsumable {
   func consume(URL: URL) -> Bool
}

extension URLConsumable {
   func consume(URL: URL) -> Bool {
      print("Default consume(URL: URL) implementation.  Arguments: URL=\(URL)")
      return false
   }
}


extension TokenCenter : URLConsumable {
   public func consume(URL: URL) -> Bool {
      guard let token = makeToken(from: URL) else {
         return false
      }

   }

   private func makeToken(from url: URL) -> Token? {
      /*
       URI scheme: otpauth://TYPE/LABEL?PARAMETERS

       TYPE: (totp) or (hotp)
       LABEL: (accountname) or (issuer\:*\saccountname) where \: is one of [:,%3A] and \s is %20
       PARAMETERS:
       secret     Required          Base32 encoded
       issuer     Recommended       URL encoded, equal to LABEL if both are present
       algorithm  Optional,#sha1    SHA1, SHA256, SHA512
       digits     Optional,#6       6-8 digit output
       counter    hotp-Required     Initial HOTP counter
       period     totp-Optional,#30 TOTP time step in seconds
       */
      let type = url.host
      let labelValue: String? = url.pathComponents.first
      let secretValue: String? = url.queryValue(for: "secret")
      let issuerValue: String? = url.queryValue(for: "issuer")
      let algorithmValue: String = url.queryValue(for: "algorithm") ?? "sha1"
      let digitsValue: String = url.queryValue(for: "digits") ?? "6"
      let periodValue: String = url.queryValue(for: "period") ?? "30"

      guard type == "totp",
         let label = labelValue,
         let (accountName, issuerFromLabel) = parse(LABEL: label),
         let secret = secretValue,
         let interval = Double(periodValue),
         let method = Token.Generator.HashMethod(rawValue: algorithmValue),
         let digits = Int(digitsValue),
         let issuer = issuerFromLabel ?? issuerValue,
         (issuerFromLabel == nil || issuerFromLabel == issuer),
         (issuerValue == nil || issuerValue == issuer) else {
            return nil
      }

      var endpoints: [Token.Endpoint:Token.WebService] = [:]
      if let registration = url.queryValue(for: "registration"),
         let URL = URL(string: registration) {
         endpoints[.registration] = Token.WebService(url: URL)
      }
      if let ack = url.queryValue(for: "ack"),
         let URL = URL(string: ack) {
         endpoints[.ack] = Token.WebService(url: URL)
      }

      let generator = Token.Generator(interval: interval, method: method, digits: digits, secret: secret)
      let origin = Token.Organization(name: issuer, accountName: accountName)
      let token = Token(name: "Unnamed", issuer: origin, generator: generator, endpoints: endpoints, uuid: UUID().uuidString)
      return token
   }

   private func parse(LABEL label: String) -> (String,String?)? {
      guard let label = label.removingPercentEncoding else {
         return nil
      }

      let pieces = label.components(separatedBy: ":")
      guard !pieces.isEmpty, pieces.count < 3 else {
         return nil
      }

      let accountName = pieces.last!.trimmingCharacters(in: .whitespaces);
      let issuer = (pieces.count == 2) ? pieces[0] : nil
      return (accountName, issuer)
   }
}

private extension URL {
   func queryValue(for key:String) -> String? {
      let components = URLComponents(url: self, resolvingAgainstBaseURL: false)
      let queryItems = components?.queryItems
      let item = queryItems?.first(where: { $0.name == key })
      return item?.value
   }
}

