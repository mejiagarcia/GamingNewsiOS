//
//  MainTabBarController.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    // MARK: - Properties
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Private Methods
    
    /**
     Method to setup the UI.
     */
    private func setupUI() {
        title = "tabs.home".localized
        
        tabBar.isTranslucent = true
        UITabBar.appearance().tintColor = UIColor.GamingNews.red
        
        // HomeViewController
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = UITabBarItem(title: "tabs.home".localized,
                                                     image: UIImage(named: "ic_all"),
                                                     tag: 0)
        
        // FavoritesViewController
        let favoritesViewController = FavoritesViewController()
        favoritesViewController.tabBarItem = UITabBarItem(title: "tabs.favorites".localized,
                                                          image: UIImage(named: "ic_star_on"),
                                                          tag: 1)
        
        // SettingsViewController
        let settingsViewController = SettingsViewController()
        settingsViewController.tabBarItem = UITabBarItem(title: "tabs.settings".localized,
                                                         image: UIImage(named: "ic_settings"),
                                                         tag: 2)
        
        viewControllers = [
            homeViewController,
            favoritesViewController,
            settingsViewController
        ]
        
        selectedIndex = 0
    }
}
