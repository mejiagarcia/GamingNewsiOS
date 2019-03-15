//
//  APIManagerProtocol.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/15/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation

protocol APIManagerProtocol {
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }
    
    func get<T: Codable>(with endpoint: Endpoint, keyPath: String?, completionHandler: @escaping (T?, Error?) -> Void)
    func getNewsFromRSS(with endpoint: String, completionHandler: @escaping ([News]?, Error?) -> Void)
}
