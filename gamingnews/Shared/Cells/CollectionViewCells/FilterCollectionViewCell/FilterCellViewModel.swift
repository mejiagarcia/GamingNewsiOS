//
//  FilterCellViewModel.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/19/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation
import UIKit

struct FilterCellViewModel: FilterCollectionViewCellDataSource {
    let title: String
    let titleFont: UIFont?
    let titleColor: UIColor?
    let backgroundColor: UIColor?
    let iconImage: UIImage?
    let iconImageTintColor: UIColor?
    
    init(title: String,
         titleFont: UIFont? = nil,
         titleColor: UIColor? = nil,
         backgroundColor: UIColor? = nil,
         iconImage: UIImage? = nil,
         iconImageTintColor: UIColor? = nil) {
        
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
        self.iconImage = iconImage
        self.iconImageTintColor = iconImageTintColor
    }
}
