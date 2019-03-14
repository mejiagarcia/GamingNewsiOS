//
//  Dialogs.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit
import Localize

class Dialogs {
    
    /**
     Method to display a basic native dialog.
     - parameter ViewController: view controller to display the dialog.
     - parameter style: Style of the dialog.
     - parameter title: Title of the dialog.
     - parameter message: Message of the dialog.
     - parameter okText: Ok Button text.
     - parameter okHandler: Block to execute when the user taps the `ok` button.
     */
    static func showAlertDialog(in viewController: UIViewController,
                                style: UIAlertController.Style = .alert,
                                title: String = "appName".localized,
                                message: String,
                                okText: String = "Ok",
                                okHandler: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        let okAction = UIAlertAction(title: okText, style: .default) { _ in
            okHandler?()
        }
        
        alert.addAction(okAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
