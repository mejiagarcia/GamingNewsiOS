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
    private var currentItem: News {
        return News(title: "", description: "", link: customTitle, pubDate: nil)
    }
    
    private(set) var webUrl: String
    private(set) var customTitle: String
    
    // MARK: - Life Cycle
    init(webUrl: String, customTitle: String) {
        self.webUrl = webUrl
        self.customTitle = customTitle
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
