//
//  UICollectionView+Extensions.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

extension UICollectionView {
    func registerCells(_ cells: [UICollectionViewCell.Type]) {
        cells.forEach {
            register(UINib(nibName: String(describing: $0.self), bundle: nil),
                     forCellWithReuseIdentifier: String(describing: $0.self))
        }
    }
    
    func registerAllCells() {
        registerCells([
            FilterCollectionViewCell.self
        ])
    }
}
