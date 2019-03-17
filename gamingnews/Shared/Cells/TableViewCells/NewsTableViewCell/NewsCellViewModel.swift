//
//  NewsCellViewModel.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

struct NewsCellViewModel: NewsTableViewCellDataSource {
    let backgroundImageUrl: String?
    let title: String
    let titleFont: UIFont?
    let titleColor: UIColor?
    let websiteUrl: String?
    
    init(backgroundImageUrl: String?,
         title: String,
         titleFont: UIFont? = nil,
         titleColor: UIColor? = nil,
         websiteUrl: String? = nil) {
        
        self.backgroundImageUrl = backgroundImageUrl
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.websiteUrl = websiteUrl
    }
}
