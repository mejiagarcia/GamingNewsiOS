//
//  APIManager.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/15/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation
import Alamofire
import CodableAlamofire
import SWXMLHash

class APIManager: APIManagerProtocol {
    // MARK: - Properties
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    init() {
        decoder.dateDecodingStrategy = .secondsSince1970
    }
    
    /**
     Method to fetch any Codable entity from a web service.
     - parameter endpoint: Endpoint to fetch.
     - parameter keyPath: The keyPath where object decoding should be performed. Default: `nil`
     - parameter completionHandler: The code to be executed once the request has finished and the data has been mapped by `JSONDecoder`.
     */
    func get<T: Codable>(with endpoint: Endpoint,
                         keyPath: String? = nil,
                         completionHandler: @escaping (T?, Error?) -> Void) {
        
        Alamofire.request(APIManager.getEndpoint(endpoint),
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: APIManager.getRequestHeaders())
            .validate()
            .responseDecodableObject(keyPath: keyPath, decoder: decoder) { (response: DataResponse<T>) in
                
                if let error = response.error {
                    completionHandler(nil, error)
                    return
                }
                if let value = response.result.value {
                    completionHandler(value, nil)
                    return
                }
                completionHandler(nil, nil)
        }
    }
    
    /**
     Method to fetch any XML result from a web service.
     - parameter endpoint: Endpoint to fetch.
     - parameter completionHandler: The code to be executed once the request has finished and the data has been mapped by `JSONDecoder`.
     */
    func getNewsFromRSS(with endpoint: String,
                        completionHandler: @escaping ([News]?, Error?) -> Void) {
        
        guard let url = URL(string: endpoint) else {
            completionHandler(nil, nil)
            
            return
        }
        
        Alamofire.request(url,
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: APIManager.getRequestHeaders())
            .validate()
            .response { dataResponse in
                guard let data = dataResponse.data else {
                    completionHandler(nil, dataResponse.error)
                    
                    return
                }
                
                let keys = News.XMLKeys.self
                let xml = SWXMLHash.parse(data)
                let xmlItems = xml[keys.rss][keys.channel][keys.item].all
                
                let result: [News] = xmlItems.map {
                    return News(title: $0[keys.title].element?.text ?? "",
                                description: $0[keys.description].element?.text ?? "",
                                link: $0[keys.link].element?.text ?? "",
                                pubDate: $0[keys.pubDate].element?.text ?? "")
                }
                
                completionHandler(result, dataResponse.error)
            }
    }
    
    /**
     Method to get a full-build endpoint ready to use.
     - parameter endpoint: Endpoint requested.
     - returns: URL with the full request.
     */
    static func getEndpoint(_ endpoint: Endpoint) -> URL {
        return URL(string: "\(Endpoint.baseUrl.path)\(endpoint.path)")!
    }
    
    /**
     Method to get the headers configuration used in all the HTTP request in the app.
     - returns: A string:string dictionary.
     */
    static func getRequestHeaders() -> HTTPHeaders {
        return [
            Constants.Api.contentTypeName: Constants.Api.contentType
        ]
    }
    
    static func getCustomURLRequest(_ url: Endpoint, data serializedObject: Data) -> URLRequest {
        var request = URLRequest(url: APIManager.getEndpoint(url))
        request.httpMethod = HTTPMethod.post.rawValue
        
        APIManager.getRequestHeaders().forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        request.httpBody = serializedObject
        
        return request
    }
}
