//
//  MainNavigationController.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    // MARK: - Properties
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Private Methods
    
    /**
     Method to setup the UI.
     **/
    private func setupUI() {
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
        }
        
        viewControllers = [MainTabBarController()]
    }
}
