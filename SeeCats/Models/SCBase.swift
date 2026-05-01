//
//  SCBase.swift
//  SeeCats
//
//  Created by Soren Inis Ngo on 12/04/2026.
//

import ObjectMapper
import Foundation
import Alamofire

class SCBase: NSObject, Mappable {
  class func collectionName() -> String {
    fatalError("This method must be overridden")
  }
  
  class func primaryKey() -> String {
    fatalError("This method must be overridden")
  }
  
  class func mapObject(jsonObject: NSDictionary) -> SCBase? {
    fatalError("This method must be overridden")
  }
  
  override init() {}
  
  required init?(map: ObjectMapper.Map) {}
  
  func mapping(map: ObjectMapper.Map) {
    fatalError("This method must be overridden")
  }
  
  func validate() -> (ModelValidationError, String?) {
    fatalError("This method must be overridden")
  }
  
  class func find(withId id: String) async throws -> SCBase? {
    let colName = collectionName()
    let url = baseAPIURL.appending(components: colName, id)
    
    let headers: HTTPHeaders = [
      "x-api-key": "DEMO-API-KEY"
    ]
    
    let task = AF.request(url, method: .get, headers: headers)
      .validate()
      .serializingData()
    
    let response = await task.response
    
    switch response.result {
    case .success(let data):
      let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
      let resultDict = jsonObject as! NSDictionary
      let resultModel = self.mapObject(jsonObject: resultDict)
      return resultModel
    case .failure(let error):
      throw error
    }
  }
  
  class func delete(withId id: String) async throws {
    let colName = collectionName()
    let url = baseAPIURL.appending(components: colName, id)
    
    let headers: HTTPHeaders = [
      "Content-Type": "application/json",
      "x-api-key": "DEMO-API-KEY"
    ]
    
    let task = AF.request(url, method: .delete, headers: headers)
      .validate()
      .serializingData()
    
    let response = await task.response
    
    switch response.result {
    case .success:
      break
    case .failure(let error):
      throw error
    }
  }
}
