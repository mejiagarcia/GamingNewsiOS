//
//  Endpoint.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/15/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation

enum Endpoint {
    case baseUrl
    
    var path: String {
        let endpoints = Constants.Api.Endpoints.self
        
        switch self {
        case .baseUrl:
            return getConfiguredUrl(key: endpoints.baseUrl)
        }
    }
    
    static var dictionaryOfEndpoints: NSDictionary? {
        guard let path = Bundle.main.path(forResource: Constants.Api.EndpointsFile.name, ofType: Constants.Api.EndpointsFile.extension) else {
            return nil
        }
        
        return NSDictionary(contentsOfFile: path)
    }
    
    private func getConfiguredUrl(key: String, customParams: [String: String] = [:]) -> String {
        guard let dictionary = Endpoint.dictionaryOfEndpoints else {
            return ""
        }
        
        let endpoint = dictionary.value(forKey: key) as? String ?? ""
        
        var fixedString = endpoint
        
        customParams.forEach { (key, value) in
            fixedString = fixedString.replacingOccurrences(of: "{\(key)}", with: value)
        }
        
        return fixedString
    }
}
