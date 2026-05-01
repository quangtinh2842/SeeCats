//
//  CommonTypes.swift
//  SeeCats
//
//  Created by Soren Inis Ngo on 12/04/2026.
//

import Foundation

let baseAPIURL = URL(string: "https://api.thecatapi.com/v1")!
let apiKey = "live_PrWhdik4H6dSiFluaHhXgWZ5gl7B7JOoEwoHt5fJUC1tegHjYo042Ajjv5fClkG8"

let NotFoundError: NSError = {
  return NSError(domain: "Not found", code: -1002, userInfo: [NSLocalizedDescriptionKey: "Result(s) not found"])
}()

enum ModelValidationError: Error {
  case Valid
  case InvalidId
  case InvalidTimestamp
  case InvalidBlankAttribute
}

enum HTTPMethods: String {
  case GET, POST, PUT, DELETE
}
