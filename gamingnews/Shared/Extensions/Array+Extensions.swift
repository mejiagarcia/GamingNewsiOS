//
//  Array+Extensions.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation

extension Array {
    func safeContains(_ index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
