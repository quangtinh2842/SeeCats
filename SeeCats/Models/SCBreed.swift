//
//  SCBreed.swift
//  SeeCats
//
//  Created by Soren Inis Ngo on 12/04/2026.
//

import Foundation
import ObjectMapper

class SCBreed: SCBase {
  @objc var id: String?
  var weight: SCWeight?
  var name: String?
  var vetstreet_url: String?
  var temperament: String?
  var origin: String?
  var country_codes: String?
  var country_code: String?
  var breedDescription: String?
  var life_span: String?
  var indoor: Int?
  var alt_names: String?
  var adaptability: Int?
  var affection_level: Int?
  var child_friendly: Int?
  var dog_friendly: Int?
  var energy_level: Int?
  var grooming: Int?
  var health_issues: Int?
  var intelligence: Int?
  var shedding_level: Int?
  var social_needs: Int?
  var stranger_friendly: Int?
  var vocalisation: Int?
  var experimental: Int?
  var hairless: Int?
  var natural: Int?
  var rare: Int?
  var rex: Int?
  var suppressed_tail: Int?
  var short_legs: Int?
  var wikipedia_url: String?
  var hypoallergenic: Int?
  var reference_image_id: String?
  
  override class func collectionName() -> String {
    return "breeds"
  }
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  override class func mapObject(jsonObject: NSDictionary) -> SCBase? {
    return Mapper<SCBreed>().map(JSONObject: jsonObject)
  }
  
  override init() { super.init() }
  
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
    id                 <- map["id"]
    weight             <- map["weight"]
    name               <- map["name"]
    vetstreet_url      <- map["vetstreet_url"]
    temperament        <- map["temperament"]
    origin             <- map["origin"]
    country_codes      <- map["country_codes"]
    country_code       <- map["country_code"]
    breedDescription   <- map["description"]
    life_span          <- map["life_span"]
    indoor             <- map["indoor"]
    alt_names          <- map["alt_names"]
    adaptability       <- map["adaptability"]
    affection_level    <- map["affection_level"]
    child_friendly     <- map["child_friendly"]
    dog_friendly       <- map["dog_friendly"]
    energy_level       <- map["energy_level"]
    grooming           <- map["grooming"]
    health_issues      <- map["health_issues"]
    intelligence       <- map["intelligence"]
    shedding_level     <- map["shedding_level"]
    social_needs       <- map["social_needs"]
    stranger_friendly  <- map["stranger_friendly"]
    vocalisation       <- map["vocalisation"]
    experimental       <- map["experimental"]
    hairless           <- map["hairless"]
    natural            <- map["natural"]
    rare               <- map["rare"]
    rex                <- map["rex"]
    suppressed_tail    <- map["suppressed_tail"]
    short_legs         <- map["short_legs"]
    wikipedia_url      <- map["wikipedia_url"]
    hypoallergenic     <- map["hypoallergenic"]
    reference_image_id <- map["reference_image_id"]
  }
  
  override func validate() -> (ModelValidationError, String?) {
    return (.Valid, nil)
  }
}

extension SCBreed {
  class SCWeight: Mappable {
    var imperial: String?
    var metric: String?
    
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
      imperial          <- map["imperial"]
      metric            <- map["metric"]
    }
  }
}
