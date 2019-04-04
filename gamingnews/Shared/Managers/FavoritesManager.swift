//
//  FavoritesManager.swift
//  gamingnews
//
//  Created by Carlos Mejia on 4/4/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation
import Disk

protocol FavoritesManagerProtocol {
    func getAll() -> [News]
    func isFavoriteSaved(_ item: News) -> Bool
    func save(_ item: News)
    func delete(_ item: News)
    func deleteAll()
}

class FavoritesManager: FavoritesManagerProtocol {
    // MARK: - Properties
    static let shared = FavoritesManager()
    private let containerName = "favorites.json"
    
    // MARK: - Life Cycle
    private init() {}
    
    // MARK: - Public Methods
    
    /**
     Method to fetch the favorite list.
     - returns: Array of saved news.
     */
    func getAll() -> [News] {
        if let retrievedData = try? Disk.retrieve(containerName, from: .applicationSupport, as: [News].self) {
            return retrievedData
        }
        
        return []
    }
    
    /**
     Method to check if the required favorite is already saved.
     - returns: `true` if the favorite is saved, false if not.
     */
    func isFavoriteSaved(_ item: News) -> Bool {
        return getAll().filter { $0.link == item.link }.first != nil
    }
    
    /**
     Method to save a favorite.
     - parameter item: NewsItemProtocol to save.
     */
    func save(_ item: News) {
        guard getAll().filter({ $0.link == item.link }).isEmpty else {
            print("Item already saved!!")
            
            return
        }
        
        var currentSavedItems = getAll()
        currentSavedItems.append(item)
        
        try? Disk.save(currentSavedItems, to: .applicationSupport, as: containerName)
    }
    
    /**
     Method to delete a favorite.
     - parameter item: NewsItemProtocol to delete.
     */
    func delete(_ item: News) {
        let currentSavedItems = getAll().filter { $0.link != item.link }
        
        try? Disk.remove(containerName, from: .applicationSupport)
        try? Disk.save(currentSavedItems, to: .applicationSupport, as: containerName)
    }
    
    /**
     Method to delete all the favorites stored.
     */
    func deleteAll() {
        try? Disk.remove(containerName, from: .applicationSupport)
    }
}
