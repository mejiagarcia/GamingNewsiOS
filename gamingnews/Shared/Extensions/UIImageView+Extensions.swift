//
//  UIImageView+Extensions.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

extension UIImageView {
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        tintColorDidChange()
    }
}
