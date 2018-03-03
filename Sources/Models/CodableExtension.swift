//
//  CodableExtension.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 3/3/18.
//  Copyright © 2018 Epic. All rights reserved.
//

import Foundation

//: Decodable Extension

extension Decodable {
   //example let people = try [Person].decode(JSONData: data)
   static func decode(fromJSON data: Data) throws -> Self {
      let decoder = JSONDecoder()
      return try decoder.decode(Self.self, from: data)
   }
}

//: Encodable Extension

extension Encodable {
   //example let jsonData = try people.encode()
   func encodeJSON() throws -> Data {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      return try encoder.encode(self)
   }
}


//: Encodable Extension

extension Dictionary {
   func encodeJSON() throws -> Data {
      return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
   }
}
