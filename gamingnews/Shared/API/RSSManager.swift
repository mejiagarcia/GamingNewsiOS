//
//  RSSManager.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation

class RSSManager {
    // MARK: - Properties
    private var decoder = JSONDecoder()
    
    // MARK: - Life Cycle
    init() {
    }
    
    // MARK: - Public Methods
    
    /**
     Method to parse the local JSON file into the required model.
     */
    func getLocalUrlsAsObject() -> [RSSUrls]? {
        guard
            let path = Bundle.main.url(forResource: "RSSUrls", withExtension: "json"),
            let data = try? Data(contentsOf: path) else {
            return nil
        }
        
        return try? decoder.decode([RSSUrls].self, from: data)
    }
}
