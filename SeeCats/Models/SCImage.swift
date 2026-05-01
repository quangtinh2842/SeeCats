//
//  SCImage.swift
//  SeeCats
//
//  Created by Soren Inis Ngo on 12/04/2026.
//

import Foundation
import ObjectMapper
import Alamofire

class SCImage: SCBase {
  @objc var id: String?
  var url: String?
  var width: Int?
  var height: Int?
  var breeds: [SCBreed]?
  
  override class func collectionName() -> String {
    return "images"
  }
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  override class func mapObject(jsonObject: NSDictionary) -> SCBase? {
    return Mapper<SCImage>().map(JSONObject: jsonObject)
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
    id              <- map["id"]
    url             <- map["url"]
    width           <- map["width"]
    height          <- map["height"]
    breeds          <- map["breeds"]
  }
  
  override func validate() -> (ModelValidationError, String?) {
    return (.Valid, nil)
  }
  
  class func upload(withData data: Data) async throws -> SCImage {
    let colName = self.collectionName()
    let url = baseAPIURL.appending(components: colName, "upload")
    
    let headers: HTTPHeaders = [
      "x-api-key": "DEMO-API-KEY"
    ]
    
    let task = AF.upload(multipartFormData: { multipartFormData in
      multipartFormData.append(data, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
    }, to: url, method: .post, headers: headers)
      .validate()
      .serializingData()
    
    let response = await task.response
    
    switch response.result {
    case .success(let data):
      let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
      let resultDict = jsonObject as! NSDictionary
      let resultModel = self.mapObject(jsonObject: resultDict) as! SCImage
      return resultModel
    case .failure(let error):
      throw error
    }
  }
  
  class func search(WithParams searchParams: QueryParams? = nil) async throws -> [SCImage] {
    let colName = self.collectionName()
    
    var urlComponents = URLComponents(url: baseAPIURL.appending(components: colName, "search"), resolvingAgainstBaseURL: false)
    let params = searchParams?.params() ?? [:]
    urlComponents?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
    guard let finalURL = urlComponents?.url else { return [] }
    
    var request = URLRequest(url: finalURL)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = HTTPMethods.GET.rawValue
    
    return try await withCheckedThrowingContinuation { continuation in
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else {
          let json = try! JSONSerialization.jsonObject(with: data!, options: [])
          let images = Mapper<SCImage>().mapArray(JSONObject: json) ?? []
          continuation.resume(returning: images)
        }
      }
      
      task.resume()
    }
  }
  
  class func getAnalysis(withId id: String) async throws -> ImageAnalysis {
    let colName = collectionName()
    let url = baseAPIURL.appending(components: colName, id, "analysis")
    
//    let headers: HTTPHeaders = [
//      "x-api-key": "DEMO-API-KEY"
//    ]
    
//    let params: [String: String] = [
//      "sub_id": ""
//    ]
    
    let task = AF.request(url, method: .get)
      .validate()
      .serializingData()
    
    let response = await task.response
    
    switch response.result {
    case .success(let data):
      let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
      let analysisElements = Mapper<SCImageAnalysisElement>().mapArray(JSONObject: jsonObject) ?? []
      let imageAnalysis = ImageAnalysis(elements: analysisElements)
      return imageAnalysis
    case .failure(let error):
      throw error
    }
  }
  
  class func getYourUploads(withParams params: SCImage.QueryParams) {
    
  }
}

extension SCImage {
  struct QueryParams: Encodable {
    enum Size: String, Codable {
      case thumb, small, med, full
    }
    
    enum MimeTypes: String, Codable {
      case jpg, png, gif
    }
    
    enum Format: String, Codable {
      case json, src
    }
    
    enum Order: String, Codable {
      case RANDOM, ASC, DESC
    }
    
    var size: QueryParams.Size? = nil
    var mime_types: QueryParams.MimeTypes? = nil
    var format: QueryParams.Format? = nil
    var has_breeds: Bool? = nil
    var order: QueryParams.Order? = nil
    var page: Int? = nil
    var limit: Int? = nil
    var include_breeds: Int? = nil
    var include_categories: Int? = nil
    var api_key: String? = nil
    var sub_id: String? = nil
    var breed_ids: [String]? = nil
    var category_ids: [String]? = nil
    var original_filename: String? = nil
    var user_id: String? = nil
    
    func toJSONData() throws -> Data {
      let encoder = JSONEncoder()
      return try encoder.encode(self)
    }
    
    func toJSONString() throws -> String {
      let data = try self.toJSONData()
      return String(data: data, encoding: .utf8)!
    }
    
    func params() -> [String: String] {
      var dict = [String: String]()
      
      guard let data = try? self.toJSONData(),
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
        return dict
      }
      
      for (key, value) in json {
        dict[key] = "\(value)"
      }
      
      return dict
    }
    
    static func defaultSearchParams() -> QueryParams {
      var params = SCImage.QueryParams()
      params.size = .med
      params.mime_types = .jpg
      params.format = .json
      params.has_breeds = true
      params.order = .DESC
      params.page = 0
      params.limit = 25
      params.include_breeds = 1
      params.include_categories = 1
      params.api_key = apiKey
      
      return params
    }
    
    static func defaultUploadedImagesGettingParams() -> QueryParams {
      var params = SCImage.QueryParams()
      params.limit = 10
      params.page = 0
      params.order = .DESC
      params.sub_id = nil
      params.breed_ids = nil
      params.category_ids = nil
      params.format = .json
      params.original_filename = nil
      params.user_id = nil
      
      return params
    }
  }
}
