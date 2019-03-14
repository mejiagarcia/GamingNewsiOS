//
//  ConfigurableCell.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import Foundation
import UIKit

protocol ConfigurableCellProtocol {
    func setupWith(dataSource: Any, indexPath: IndexPath?, delegate: Any?)
}
