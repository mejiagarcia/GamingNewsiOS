//
//  NewsDetailViewModel.swift
//  gamingnews
//
//  Created by Carlos Mejia on 4/4/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation

struct NewsDetailViewModel {
    // MARK: - Properties
    private var favoritesManagaer = FavoritesManager.shared
    private(set) var currentItem: News
    
    // MARK: - Life Cycle
    init(title: String, description: String, link: String, pubDate: String?) {
        currentItem = News(title: title, description: description, link: link, pubDate: pubDate)
    }
    
    // MARK: - Public Methods
    
    func toggleFavorite() {
        guard !isCurrentFavoriteSaved() else {
            favoritesManagaer.delete(currentItem)
            
            return
        }
        
        favoritesManagaer.save(currentItem)
    }
    
    func isCurrentFavoriteSaved() -> Bool {
        return favoritesManagaer.isFavoriteSaved(currentItem)
    }
}
