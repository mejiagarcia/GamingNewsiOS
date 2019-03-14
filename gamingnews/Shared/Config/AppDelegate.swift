//
//  AppDelegate.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit
import Localize

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupLang()
        setupInitialVC()
        
        return true
    }
    
    // MARK: - Private Methods
    
    /**
     Method to create the main window and the initial view controller to show.
    **/
    private func setupInitialVC() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainTabBarController()
        window?.makeKeyAndVisible()
    }
    
    /**
     Method to setup the man language of the app
     **/
    private func setupLang() {
        let localize = Localize.shared
        localize.update(provider: .json)
        localize.update(fileName: "lang")
        localize.update(defaultLanguage: Constants.General.Lang.english)
    }
}
