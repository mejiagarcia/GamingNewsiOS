//
//  FavoriteCellViewModel.swift
//  gamingnews
//
//  Created by Carlos Mejia on 4/4/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

struct FavoriteCellViewModel: FavoriteCellDataSource {
    let imageURL: String
    let title: String
    let titleFont: UIFont?
    let titleColor: UIColor?
    
    init(imageURL: String, title: String, titleFont: UIFont? = nil, titleColor: UIColor? = nil) {
        self.imageURL = imageURL
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
    }
}
