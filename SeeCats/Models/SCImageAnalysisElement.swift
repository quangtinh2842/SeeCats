//
//  SCImageAnalysisElement.swift
//  SeeCats
//
//  Created by Soren Inis Ngo on 15/04/2026.
//

import Foundation
import ObjectMapper

class SCImageAnalysisElement: SCBase {
  var labels: [SCImageAnalysisElement.Label]?
  var moderation_labels: [SCImageAnalysisElement.Label]? // not sure about the type
  var vendor: String?
  var image_id: String?
  var created_at: String?
  
  required init?(map: ObjectMapper.Map) {
    super.init(map: map)
    
    let attributes = [String]()
    let validations = attributes.map {
      map[$0].currentValue != nil
    }.reduce(true) { $0 && $1 }
    
    if !validations {
      return nil
    }
  }
  
  override func mapping(map: ObjectMapper.Map) {
    labels              <- map["labels"]
    moderation_labels   <- map["moderation_labels"]
    vendor              <- map["vendor"]
    image_id            <- map["image_id"]
    created_at          <- map["created_at"]
  }
}

extension SCImageAnalysisElement {
  class Label: Mappable {
    var Name: String?
    var Confidence: Double?
    
    required init?(map: ObjectMapper.Map) {
      let attributes = [String]()
      let validations = attributes.map {
        map[$0].currentValue != nil
      }.reduce(true) { $0 && $1 }
      
      if !validations {
        return nil
      }
    }
    
    func mapping(map: ObjectMapper.Map) {
      Name              <- map["Name"]
      Confidence        <- map["Confidence"]
    }
  }
}
