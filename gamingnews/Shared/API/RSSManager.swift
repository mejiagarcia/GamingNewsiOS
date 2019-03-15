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
    static let shared = RSSManager()
    private var decoder = JSONDecoder()
    private(set) var urls = [RSSUrls]()
    
    // MARK: - Life Cycle
    private init() {
        getLocalUrlsAsObject()
    }
    
    // MARK: - Private Methods
    
    /**
     Method to parse the local JSON file into the required model.
     */
    private func getLocalUrlsAsObject() {
        guard
            let path = Bundle.main.url(forResource: "RSSUrls", withExtension: "json"),
            let data = try? Data(contentsOf: path) else {
            return
        }
        
        if let urls = try? decoder.decode([RSSUrls].self, from: data) {
            self.urls = urls
        }
    }
}
