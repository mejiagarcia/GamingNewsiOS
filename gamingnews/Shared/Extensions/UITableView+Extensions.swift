//
//  UITableView+Extensions.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

extension UITableView {
    /**
     Method to register an array of cells by the type.
     - parameter cells: Array of cells.
     */
    func registerCells(_ cells: [UITableViewCell.Type]) {
        cells.forEach {
            register(UINib(nibName: String(describing: $0.self), bundle: nil),
                     forCellReuseIdentifier: String(describing: $0.self))
        }
    }
    
    /**
     Method to register all the cells in the project.
     */
    func registerAllCells() {
        // Only class cells
        register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.getReuseIdentifier())
        
        // Xib cells
        registerCells([
            NewsTableViewCell.self
        ])
    }
}
