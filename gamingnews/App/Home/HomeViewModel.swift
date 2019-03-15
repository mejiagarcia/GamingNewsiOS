//
//  HomeViewModel.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation

class HomeViewModel {
    // MARK: - Properties
    private var apiManager: APIManagerProtocol
    private(set) var dataSource = [ConfigurableCell]()
    weak var delegate: BaseViewModelProtocol?
    
    // MARK: - Life Cycle
    init(apiManager: APIManagerProtocol = APIManager()) {
        self.apiManager = apiManager
    }
    
    // MARK: - Public Methods
    
    /**
     Method to fetch the data from the server.
     */
    func fetchData() {
        delegate?.performLoading(isLoadig: true)
        
        guard let allUrl = RSSManager.shared.urls.filter({ $0.language == RSSUrlsLang.spanish }).first?.all.first else {
            return
        }
        
        apiManager.getNewsFromRSS(with: allUrl) { [weak self] (result: [News]?, error) in
            guard let self = self else {
                return
            }
            
            self.delegate?.performLoading(isLoadig: false)
            
            guard let result = result else {
                self.delegate?.performNetworkResult(.error(meesage: error?.localizedDescription))
                
                return
            }
            
            self.dataSource = result.map {
                let viewModel = NewsCellViewModel(backgroundImageUrl: $0.imageUrl, title: $0.title)
                
                return ConfigurableCell(identifier: NewsTableViewCell.getReuseIdentifier(), viewModel: viewModel)
            }
            
            self.delegate?.performLoading(isLoadig: false)
            self.delegate?.requestLoaded()
        }
    }
}
