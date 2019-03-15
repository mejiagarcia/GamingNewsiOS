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
    private(set) var dataSource = [ConfigurableCell]()
    weak var delegate: BaseViewModelProtocol?
    
    // MARK: - Life Cycle
    
    // MARK: - Public Methods
    
    /**
     Method to fetch the data from the server.
     */
    func fetchData() {
        delegate?.performLoading(isLoadig: true)
        
        for _ in 0..<20 {
            let viewModel = NewsCellViewModel(backgroundImageUrl: "", title: "Jejejejejjejejejejeje")
            dataSource.append(ConfigurableCell(identifier: NewsTableViewCell.getReuseIdentifier(), viewModel: viewModel))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.delegate?.performLoading(isLoadig: false)
            self?.delegate?.requestLoaded()
        }
    }
}
