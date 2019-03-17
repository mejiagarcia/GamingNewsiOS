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
    func fetchData(_ index: Int = 0) {
        delegate?.performLoading(isLoadig: true)
        
        guard let currentUrl = RSSManager.shared.urls.filter({ $0.language == RSSUrlsLang.spanish }).first?.all.safeContains(index) else {
            sortDataSourceByDate()
            delegate?.performLoading(isLoadig: false)
            delegate?.requestLoaded()
            
            return
        }
        
        apiManager.getNewsFromRSS(with: currentUrl) { [weak self] (result: [News]?, error) in
            guard let self = self else {
                return
            }
            
            self.delegate?.performLoading(isLoadig: false)
            
            guard let result = result else {
                self.delegate?.performNetworkResult(.error(meesage: error?.localizedDescription))
                
                return
            }
            
            result.forEach {
                let viewModel = NewsCellViewModel(backgroundImageUrl: $0.imageUrl, title: $0.title, websiteUrl: $0.link, createdAt: $0.createdAt)
                
                self.dataSource.append(ConfigurableCell(identifier: NewsTableViewCell.getReuseIdentifier(), viewModel: viewModel))
            }
            
            self.fetchData(index + 1)
        }
    }
    
    // MARK: - Private Methods
    
    /**
     Method sort the given dataSource by date.
     */
    private func sortDataSourceByDate() {
        dataSource = dataSource.sorted(by: { (item1, item2) -> Bool in
            return (item1.viewModel as? NewsCellViewModel)?.createdAt ?? Date() > (item2.viewModel as? NewsCellViewModel)?.createdAt ?? Date()
        })
    }
}
