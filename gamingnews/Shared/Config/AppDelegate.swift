//
//  AppDelegate.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit
import Localize
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupLang()
        setupFirebase()
        setupFirebasePushNotification(application)
        setupInitialVC()
        
        return true
    }
    
    // MARK: - Private Methods
    
    /**
     Method to create the main window and the initial view controller to show.
    **/
    private func setupInitialVC() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainNavigationController()
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
    
    /**
     Method to setup Firebase.
     **/
    private func setupFirebase() {
        FirebaseApp.configure()
    }
    
    /**
     Method to setup the remote Firebase notification's.
     **/
    private func setupFirebasePushNotification(_ application: UIApplication) {
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
}

// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {}
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {}
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {}
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {}
}
