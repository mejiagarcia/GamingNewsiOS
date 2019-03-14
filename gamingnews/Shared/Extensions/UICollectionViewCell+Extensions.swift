//
//  UICollectionViewCell+Extensions.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    class var getReuseIdentifier: String {
        return String(describing: self)
    }
}
